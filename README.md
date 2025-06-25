# Beancount Docker

这是一个用于构建和运行Beancount的Docker容器项目。Beancount是一个基于复式记账的个人财务管理工具。

## 功能特性

- 🐳 完整的Docker化Beancount环境
- 🌐 包含Fava Web界面，支持可视化账本管理
- 📊 支持数据导入和分析工具
- 🔧 自动化构建和部署脚本
- 📁 数据持久化支持
- 🚀 GitHub Actions自动构建并推送到Docker Hub

## CI/CD自动化

本项目配置了GitHub Actions，可以自动构建Docker镜像并推送到Docker Hub。

### 配置Docker Hub自动推送

要启用自动推送到Docker Hub，需要在GitHub仓库中配置以下Secrets：

1. 访问你的GitHub仓库 → Settings → Secrets and variables → Actions
2. 添加以下Repository secrets：
   - `DOCKERHUB_USERNAME`: 你的Docker Hub用户名
   - `DOCKERHUB_TOKEN`: 你的Docker Hub访问令牌

### 获取Docker Hub Token

1. 登录 [Docker Hub](https://hub.docker.com/)
2. 点击右上角头像 → Account Settings
3. 选择 Security → New Access Token
4. 创建一个新的访问令牌（权限选择 Read, Write, Delete）
5. 复制生成的令牌并保存到GitHub Secrets中

### 自动构建触发条件

GitHub Actions会在以下情况下自动构建和推送镜像：

- 推送到 `main` 或 `master` 分支
- 创建新的标签（格式：`v*`）
- 创建 Pull Request（仅构建，不推送）

### 镜像标签

自动构建会生成以下标签：

- `latest`: 最新的main分支版本
- `{branch-name}`: 分支名标签
- `{tag}`: 对应的Git标签
- `{major}.{minor}`: 版本号标签（如果是语义化版本标签）

## 快速开始

### 使用预构建镜像（推荐）

如果项目已配置自动构建，可以直接使用Docker Hub上的镜像：

```bash
# 拉取最新镜像
docker pull your-dockerhub-username/beancount-docker:latest

# 运行容器
docker run -d \
  --name beancount \
  -p 6000:6000 \
  -v $(pwd)/data:/data \
  your-dockerhub-username/beancount-docker:latest
```

### 使用构建脚本（本地构建）

1. **构建Docker镜像**
   ```bash
   ./build.sh build
   ```

2. **运行容器**
   ```bash
   ./build.sh run
   ```

3. **访问Web界面**
   
   打开浏览器访问: http://localhost:6000

### 使用Docker Compose

1. **启动服务**
   ```bash
   docker-compose up -d
   ```

2. **停止服务**
   ```bash
   docker-compose down
   ```

## 脚本命令

构建脚本 `build.sh` 支持以下命令：

- `build` - 构建Docker镜像
- `run` - 运行Beancount容器
- `stop` - 停止容器
- `clean` - 清理容器和镜像
- `logs` - 查看容器日志
- `shell` - 进入容器shell
- `help` - 显示帮助信息

### 示例

```bash
# 构建镜像
./build.sh build

# 运行容器
./build.sh run

# 查看日志
./build.sh logs

# 进入容器shell进行调试
./build.sh shell

# 停止容器
./build.sh stop

# 清理所有资源
./build.sh clean
```

## 目录结构

```
beancount-docker/
├── Dockerfile              # Docker镜像定义
├── docker-compose.yml      # Docker Compose配置
├── build.sh                # 构建和管理脚本
├── requirements.txt        # Python依赖
├── .dockerignore           # Docker构建忽略文件
├── .github/
│   └── workflows/
│       └── docker-build-push.yml  # GitHub Actions工作流
├── data/                   # 账本数据目录（自动创建）
│   └── main.beancount      # 示例账本文件
└── README.md              # 项目文档
```

## 数据管理

### 账本文件

账本文件存储在 `./data/` 目录中，该目录会自动挂载到容器内的 `/data` 目录。

默认的主账本文件是 `./data/main.beancount`，你可以编辑这个文件来管理你的财务记录。

### 数据持久化

所有数据都存储在宿主机的 `./data/` 目录中，容器重启后数据不会丢失。

## 自定义配置

### 修改端口

默认端口是6000，如需修改，可以：

1. 编辑 `build.sh` 脚本中的端口映射
2. 或者修改 `docker-compose.yml` 中的端口配置

### 添加更多工具

在 `requirements.txt` 中添加额外的Python包，然后重新构建镜像。

## 常见问题

### Q: 如何导入银行对账单？

A: 进入容器shell (`./build.sh shell`) 后，可以使用beancount-import等工具导入各种格式的数据。

### Q: 如何备份数据？

A: 直接备份 `./data/` 目录即可，这包含了所有的账本文件。

### Q: 容器启动失败怎么办？

A: 运行 `./build.sh logs` 查看详细错误信息。

### Q: GitHub Actions构建失败怎么办？

A: 检查以下配置：
1. 确认GitHub Secrets中的Docker Hub凭据正确
2. 检查Docker Hub用户名是否正确
3. 查看Actions日志了解具体错误信息

## 开发

如需修改Dockerfile或添加新功能：

1. 修改相应文件
2. 重新构建镜像: `./build.sh build`
3. 测试新功能: `./build.sh run`

### 版本发布

要发布新版本并自动构建Docker镜像：

```bash
# 创建并推送标签
git tag v1.0.0
git push origin v1.0.0
```

这将触发GitHub Actions自动构建并推送带有版本标签的镜像。

## 许可证

本项目采用与原始Beancount项目相同的许可证。

## 相关链接

- [Beancount官方文档](https://beancount.github.io/docs/)
- [Fava项目](https://github.com/beancount/fava)
- [Beancount中文文档](https://beancount.github.io/docs/index_cn.html)
- [Docker Hub](https://hub.docker.com/)