from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_jwt_extended import (
    JWTManager, create_access_token, jwt_required, get_jwt_identity
)
from flask_cors import CORS
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import timedelta
import os

app = Flask(__name__)
CORS(app)

@app.route('/')
def home():
    return jsonify(message="Flask backend running successfully"), 200

# CONFIG
BASE_DIR = os.path.abspath(os.path.dirname(__file__))
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///' + os.path.join(BASE_DIR, 'app.db')
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['SECRET_KEY'] = 'change-this-secret-in-prod'
app.config['JWT_SECRET_KEY'] = 'change-this-jwt-secret-in-prod'
app.config['JWT_ACCESS_TOKEN_EXPIRES'] = timedelta(days=30)  # ✅ Changed to 30 days for better UX

db = SQLAlchemy(app)
jwt = JWTManager(app)

# ✅ ADD: JWT ERROR HANDLERS
@jwt.expired_token_loader
def expired_token_callback(jwt_header, jwt_payload):
    print("❌ [FLASK] Token expired")
    return jsonify({"msg": "Token has expired"}), 401

@jwt.invalid_token_loader
def invalid_token_callback(error):
    print(f"❌ [FLASK] Invalid token: {error}")
    return jsonify({"msg": f"Invalid token: {error}"}), 422

@jwt.unauthorized_loader
def missing_token_callback(error):
    print(f"❌ [FLASK] Missing token: {error}")
    return jsonify({"msg": "Authorization token is missing"}), 401

# ✅ ADD: LOG INCOMING REQUESTS FOR DEBUGGING
@app.before_request
def log_request_info():
    if request.path.startswith('/api/'):
        print(f"\n{'='*50}")
        print(f"📥 [FLASK] {request.method} {request.path}")
        if 'Authorization' in request.headers:
            auth_header = request.headers.get('Authorization')
            print(f"🔑 [FLASK] Auth header: {auth_header[:60]}...")
        print(f"{'='*50}\n")

# -----------------------
# Models
# -----------------------
class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(150), unique=True, nullable=False)
    password_hash = db.Column(db.String(256), nullable=False)

    # Profile fields
    name = db.Column(db.String(150), default='Guest')
    age = db.Column(db.Integer, nullable=True)
    gender = db.Column(db.String(50), nullable=True)
    contact = db.Column(db.String(50), nullable=True)
    address = db.Column(db.String(300), nullable=True)

    # Health Info
    blood_group = db.Column(db.String(10), nullable=True)
    blood_pressure = db.Column(db.String(50), nullable=True)

    # Preferences
    language = db.Column(db.String(50), default='English')

    def set_password(self, password: str):
        self.password_hash = generate_password_hash(password)

    def check_password(self, password: str) -> bool:
        return check_password_hash(self.password_hash, password)

    def to_dict(self):
        return {
            "id": self.id,
            "email": self.email,
            "name": self.name,
            "age": self.age,
            "gender": self.gender,
            "contact": self.contact,
            "address": self.address,
            "blood_group": self.blood_group,
            "blood_pressure": self.blood_pressure,
            "language": self.language
        }

# -----------------------
# DB creation helper
# -----------------------
with app.app_context():
    db.create_all()
    print("✅ [FLASK] Database initialized")

# -----------------------
# Auth endpoints
# -----------------------
@app.route('/api/register', methods=['POST'])
def register():
    data = request.get_json() or {}
    email = data.get('email')
    password = data.get('password')

    print(f"📝 [FLASK] Registration attempt: {email}")

    if not email or not password:
        return jsonify({"msg": "Email and password required"}), 400

    if User.query.filter_by(email=email).first():
        print(f"❌ [FLASK] User already exists: {email}")
        return jsonify({"msg": "User already exists"}), 400

    user = User(email=email)
    user.set_password(password)
    user.name = data.get('name', user.name)
    user.contact = data.get('contact', user.contact)
    db.session.add(user)
    db.session.commit()

    print(f"✅ [FLASK] User registered: {email}")
    return jsonify({"msg": "User registered"}), 201

@app.route('/api/login', methods=['POST'])
def login():
    data = request.get_json() or {}
    email = data.get('email')
    password = data.get('password')

    print(f"🔐 [FLASK] Login attempt: {email}")

    if not email or not password:
        return jsonify({"msg": "Email and password required"}), 400

    user = User.query.filter_by(email=email).first()
    if not user or not user.check_password(password):
        print(f"❌ [FLASK] Invalid credentials for: {email}")
        return jsonify({"msg": "Invalid credentials"}), 401

    # ✅ Convert user.id to string for JWT
    access_token = create_access_token(identity=str(user.id))
    
    print(f"✅ [FLASK] User logged in: {email}")
    print(f"🔑 [FLASK] Token generated (length: {len(access_token)})")
    print(f"👤 [FLASK] User ID in token: {user.id}")
    
    return jsonify({"access_token": access_token}), 200

# -----------------------
# Protected profile endpoints
# -----------------------
@app.route('/api/profile', methods=['GET'])
@jwt_required()
def get_profile():
    user_id = get_jwt_identity()
    print(f"👤 [FLASK] Fetching profile for user_id: {user_id}")
    
    # ✅ Convert string back to int
    user = User.query.get(int(user_id))
    if not user:
        print(f"❌ [FLASK] User not found: {user_id}")
        return jsonify({"msg": "User not found"}), 404
    
    print(f"✅ [FLASK] Profile fetched: {user.email}")
    return jsonify(user.to_dict()), 200

@app.route('/api/profile', methods=['PUT'])
@jwt_required()
def update_profile():
    user_id = get_jwt_identity()
    # ✅ Convert string back to int
    user = User.query.get(int(user_id))
    if not user:
        return jsonify({"msg": "User not found"}), 404

    data = request.get_json() or {}
    
    if 'name' in data:
        user.name = data['name']
    if 'age' in data:
        try:
            user.age = int(data['age']) if data['age'] not in (None, '') else None
        except ValueError:
            return jsonify({"msg": "Invalid age"}), 400
    if 'gender' in data:
        user.gender = data['gender']
    if 'contact' in data:
        user.contact = data['contact']
    if 'address' in data:
        user.address = data['address']
    if 'language' in data:  # ✅ Added language support here too
        user.language = data['language']

    db.session.commit()
    print(f"✅ [FLASK] Profile updated: {user.email}")
    return jsonify(user.to_dict()), 200

@app.route('/api/profile/health', methods=['PUT'])
@jwt_required()
def update_health():
    user_id = get_jwt_identity()
    # ✅ Convert string back to int
    user = User.query.get(int(user_id))
    if not user:
        return jsonify({"msg": "User not found"}), 404

    data = request.get_json() or {}
    if 'blood_group' in data:
        user.blood_group = data['blood_group']
    if 'blood_pressure' in data:
        user.blood_pressure = data['blood_pressure']

    db.session.commit()
    print(f"✅ [FLASK] Health info updated: {user.email}")
    return jsonify(user.to_dict()), 200

@app.route('/api/profile/language', methods=['PUT'])
@jwt_required()
def update_language():
    user_id = get_jwt_identity()
    # ✅ Convert string back to int
    user = User.query.get(int(user_id))
    if not user:
        return jsonify({"msg": "User not found"}), 404

    data = request.get_json() or {}
    lang = data.get('language')
    if lang:
        user.language = lang
        db.session.commit()
        print(f"✅ [FLASK] Language updated: {user.email} -> {lang}")
        return jsonify({"msg": "Language updated", "language": user.language}), 200
    return jsonify({"msg": "language required"}), 400

@app.route('/api/change-password', methods=['PUT'])
@jwt_required()
def change_password():
    user_id = get_jwt_identity()
    # ✅ Convert string back to int
    user = User.query.get(int(user_id))
    if not user:
        return jsonify({"msg": "User not found"}), 404

    data = request.get_json() or {}
    old = data.get('old_password')
    new = data.get('new_password')
    if not old or not new:
        return jsonify({"msg": "old_password and new_password required"}), 400

    if not user.check_password(old):
        return jsonify({"msg": "Old password incorrect"}), 401

    user.set_password(new)
    db.session.commit()
    print(f"✅ [FLASK] Password changed: {user.email}")
    return jsonify({"msg": "Password changed"}), 200

# -----------------------
# Run
# -----------------------
if __name__ == '__main__':
    print("\n" + "="*60)
    print("🚀 [FLASK] Starting NirogNet Auth Backend")
    print("="*60)
    print("📡 [FLASK] Server URL: http://localhost:5000")
    print("📱 [FLASK] Android Emulator: http://10.0.2.2:5000")
    print("💻 [FLASK] Same WiFi Device: http://YOUR_PC_IP:5000")
    print("="*60 + "\n")
    app.run(debug=True, host='0.0.0.0', port=5000)