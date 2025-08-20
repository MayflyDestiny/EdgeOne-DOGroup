# 基础镜像
FROM python:3.12-slim

# 设置工作目录
WORKDIR /app

# 复制依赖文件
COPY requirements.txt ./

# 安装编译依赖
RUN apt-get update && apt-get install -y \
    gcc \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# 安装依赖
RUN pip install --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# 复制源代码和其他文件
COPY src ./src

# 设置环境变量
ENV PYTHONUNBUFFERED=1

# 声明挂载点
VOLUME ["/eodo"]

# 暴露端口
EXPOSE 54321

# 启动命令
CMD ["python", "src/eodo/app.py", "-p", "54321"]