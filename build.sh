#!/bin/bash

# Beancount Docker构建脚本
# 作者: Generated Script
# 描述: 构建Beancount Docker镜像的自动化脚本

set -e  # 遇到错误时立即退出

# 配置变量
IMAGE_NAME="beancount"
TAG="latest"
CONTAINER_NAME="beancount-app"
DATA_DIR="./data"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的信息
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 显示帮助信息
show_help() {
    echo "Beancount Docker构建脚本"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  build       构建Docker镜像"
    echo "  run         运行Beancount容器"
    echo "  stop        停止容器"
    echo "  clean       清理容器和镜像"
    echo "  logs        查看容器日志"
    echo "  shell       进入容器shell"
    echo "  help        显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 build           # 构建镜像"
    echo "  $0 run             # 运行容器"
    echo "  $0 shell           # 进入容器shell"
}

# 检查Docker是否安装
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker未安装，请先安装Docker"
        exit 1
    fi
    print_info "Docker已安装: $(docker --version)"
}

# 创建数据目录
create_data_dir() {
    if [ ! -d "$DATA_DIR" ]; then
        print_info "创建数据目录: $DATA_DIR"
        mkdir -p "$DATA_DIR"
        
        # 创建示例配置文件
        cat > "$DATA_DIR/main.beancount" << 'EOF'
;; Beancount示例账本文件
;; 更多信息请参考: https://beancount.github.io/docs/

option "title" "我的个人财务账本"
option "operating_currency" "CNY"

;; 账户定义
1900-01-01 open Assets:Cash:Wallet CNY
1900-01-01 open Assets:Bank:Checking CNY
1900-01-01 open Income:Salary CNY
1900-01-01 open Expenses:Food CNY
1900-01-01 open Expenses:Transport CNY

;; 示例交易
2024-01-01 * "工资"
  Income:Salary           -5000.00 CNY
  Assets:Bank:Checking     5000.00 CNY

2024-01-02 * "午餐"
  Expenses:Food             25.00 CNY
  Assets:Cash:Wallet       -25.00 CNY
EOF
        print_success "创建了示例账本文件: $DATA_DIR/main.beancount"
    fi
}

# 构建Docker镜像
build_image() {
    print_info "开始构建Docker镜像..."
    print_info "镜像名称: $IMAGE_NAME:$TAG"
    
    docker build -t "$IMAGE_NAME:$TAG" .
    
    if [ $? -eq 0 ]; then
        print_success "Docker镜像构建成功!"
        print_info "镜像大小: $(docker images $IMAGE_NAME:$TAG --format "table {{.Size}}" | tail -1)"
    else
        print_error "Docker镜像构建失败!"
        exit 1
    fi
}

# 运行容器
run_container() {
    print_info "启动Beancount容器..."
    
    # 停止现有容器（如果存在）
    if docker ps -a --format "table {{.Names}}" | grep -q "$CONTAINER_NAME"; then
        print_info "停止现有容器..."
        docker stop "$CONTAINER_NAME" >/dev/null 2>&1 || true
        docker rm "$CONTAINER_NAME" >/dev/null 2>&1 || true
    fi
    
    # 创建数据目录
    create_data_dir
    
    # 运行新容器
    docker run -d \
        --name "$CONTAINER_NAME" \
        -p 6000:6000 \
        -v "$(pwd)/$DATA_DIR:/data" \
        "$IMAGE_NAME:$TAG"
    
    if [ $? -eq 0 ]; then
        print_success "容器启动成功!"
        print_info "Fava Web界面: http://localhost:6000"
        print_info "数据目录: $(pwd)/$DATA_DIR"
        print_info "容器名称: $CONTAINER_NAME"
    else
        print_error "容器启动失败!"
        exit 1
    fi
}

# 停止容器
stop_container() {
    print_info "停止容器..."
    if docker ps --format "table {{.Names}}" | grep -q "$CONTAINER_NAME"; then
        docker stop "$CONTAINER_NAME"
        print_success "容器已停止"
    else
        print_warning "容器未在运行"
    fi
}

# 清理资源
clean_resources() {
    print_warning "这将删除容器和镜像，确定要继续吗? (y/N)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        print_info "清理容器和镜像..."
        
        # 停止并删除容器
        docker stop "$CONTAINER_NAME" >/dev/null 2>&1 || true
        docker rm "$CONTAINER_NAME" >/dev/null 2>&1 || true
        
        # 删除镜像
        docker rmi "$IMAGE_NAME:$TAG" >/dev/null 2>&1 || true
        
        print_success "清理完成"
    else
        print_info "取消清理操作"
    fi
}

# 查看日志
show_logs() {
    print_info "显示容器日志..."
    docker logs -f "$CONTAINER_NAME"
}

# 进入容器shell
enter_shell() {
    print_info "进入容器shell..."
    docker exec -it "$CONTAINER_NAME" /bin/bash
}

# 主函数
main() {
    check_docker
    
    case "${1:-help}" in
        build)
            build_image
            ;;
        run)
            run_container
            ;;
        stop)
            stop_container
            ;;
        clean)
            clean_resources
            ;;
        logs)
            show_logs
            ;;
        shell)
            enter_shell
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            print_error "未知选项: $1"
            show_help
            exit 1
            ;;
    esac
}

# 执行主函数
main "$@" 