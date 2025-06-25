# 使用官方Python镜像作为基础镜像
FROM python:3.11-slim

# 添加元数据标签
LABEL maintainer="beancount-docker"
LABEL description="Beancount with Fava web interface in Docker"
LABEL version="1.0"

# 设置工作目录
WORKDIR /app

# 设置环境变量
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# 安装系统依赖和curl（用于健康检查）
RUN apt-get update && apt-get install -y \
    build-essential \
    libxml2-dev \
    libxslt1-dev \
    zlib1g-dev \
    pkg-config \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 复制requirements文件
COPY requirements.txt .

# 安装Python依赖
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# 创建非root用户
RUN groupadd -r beancount && useradd -r -g beancount beancount

# 创建用户目录用于存放账本文件
RUN mkdir -p /data && chown beancount:beancount /data

# 切换到非root用户
USER beancount

# 设置数据目录为卷
VOLUME ["/data"]

# 暴露端口（用于fava web界面）
EXPOSE 6000

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:6000/ || exit 1

# 设置默认命令
CMD ["fava", "/data/main.beancount", "--host", "0.0.0.0", "--port", "6000"] 