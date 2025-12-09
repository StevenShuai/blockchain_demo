from cryptography.hazmat.primitives.asymmetric import rsa, padding
from cryptography.hazmat.primitives import hashes
import hashlib
import base64
import pow

def generate_key():
    """
    生成私钥公钥对
    :return: 公钥，私钥
    """

    print("开始生成RSA密钥对")
    private_key = rsa.generate_private_key(public_exponent=65537, key_size=2048)
    public_key = private_key.public_key()
    print(f"公钥: {public_key}")
    print(f"私钥: {private_key}")
    print("密钥对生成完成")

    return public_key, private_key

def sign(msg: str, private_key: str):
    """
    对消息进行签名
    :param msg: 待签名的消息
    :param private_key: 签名的私钥
    :return: 签名数据
    """

    if not msg or not private_key:
        raise ValueError("签名数据或私钥不能为空")

    print("开始使用私钥签名")
    sign_msg = private_key.sign(
        msg.encode(),
        padding.PSS(
            mgf=padding.MGF1(hashes.SHA256()),
            salt_length=padding.PSS.MAX_LENGTH
        ),
        hashes.SHA256()
    )
    print(f"签名结束，数据: {sign_msg}")
    return sign_msg

def verify_sign(msg: str, sign_msg: str, public_key: str):
    """
    对签名进行验证
    :param msg: 待签名的消息
    :param sign_msg: 签名数据
    :param public_key: 验证的公钥
    :return: true:验证成功 false:验证失败
    """

    print("开始使用公钥验证签名")
    try:
        public_key.verify(
            sign_msg,
            msg.encode(),
            padding.PSS(
                mgf=padding.MGF1(hashes.SHA256()),
                salt_length=padding.PSS.MAX_LENGTH
            ),
            hashes.SHA256()
        )
        print("签名验证成功")
        return True
    except Exception as e:
        print("签名验证失败")
        return False

if __name__ == "__main__":
    # 获取用户昵称
    nickname = None
    while not nickname:
        nickname = input("请输入你的昵称: ").strip()
    print(f"\n{"="*50}\n")

    #1. 生成公私钥对
    public_key, private_key = generate_key()
    print(f"\n{"="*50}\n")

    #2. 获取POW 4 个 0 开头的哈希值的 “昵称 + nonce” 
    elapsed, data, hash_data = pow.calculate_hash(nickname = nickname, target_value = "0000")
    print(f"\n{"="*50}\n")

    #3. 签名
    sign_data = sign(data, private_key)
    print(f"\n{"="*50}\n")

    #4. 用公钥验证签名
    verify_result = verify_sign(data, sign_data, public_key)
    
