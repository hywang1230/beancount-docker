# 使用官方 Python 3 基础镜像
FROM python:3.11-slim

# 设置环境变量
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# 安装依赖
RUN apt-get update && \
    apt-get install -y git && \
    pip install --upgrade pip && \
    pip install beancount fava

# 创建挂载点目录（可选）
RUN mkdir /data
VOLUME ["/data"]

# 设置工作目录
WORKDIR /data

# 默认运行 fava（Beancount 的 Web 前端）
EXPOSE 5000
CMD ["fava", "--host", "0.0.0.0", "main.bean"]