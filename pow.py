import hashlib
from datetime import datetime

def calculate_hash(nickname: str = "shuai", nonce: int = 0, target_value: str = "0000"):
    """
    计算生成hash函数
    :param nickname: 用户昵称
    :param nonce: 随机数初始值
    :param target_value: 计算完成目标数据
    :return: 花费时间, hash内容, hash值
    """

    print(f"开始计算hash，目标值: {target_value}")

    start_time = datetime.now()
    print(f"开始时间: {start_time}")

    # 随机数初始值
    nonce = 0

    while True:
        data = f"{nickname}{nonce}"
        hash_data = hashlib.sha256(data.encode()).hexdigest()

        if hash_data.startswith(target_value):
            print(f"目标值：{target_value} 已经生成，结束计算hash")
            end_time = datetime.now()
            print(f"结束时间: {end_time}")
            elapsed = (end_time - start_time).total_seconds()
            print(f"共用时：{elapsed}秒")
            print(f"Hash内容: {data}")
            print(f"Hash值: {hash_data}")
            return elapsed, data, hash_data
        
        nonce += 1

if __name__ == "__main__":
    target_values = ["0000", "00000"]
    for target_value in target_values:
        elapsed, data, hash_data = calculate_hash(target_value=target_value)
        print(f"\n{"="*50}\n")

