# GitHub Actions 自动构建部署指南

## 📋 概述

本项目使用 GitHub Actions 实现自动化的 CI/CD 流程，包括代码质量检查、Docker 镜像构建、安全扫描、多平台支持等功能。本文档详细说明了如何配置和使用这些自动化工作流。

## 🔧 工作流配置

### 1. Docker 镜像构建和发布 (docker-publish.yml)

#### 1.1 触发条件
- **推送到主分支**: `main` 或 `master` 分支的代码推送
- **标签推送**: 以 `v` 开头的版本标签 (如 `v1.0.0`)
- **Pull Request**: 针对主分支的 PR（仅构建，不推送）
- **Release 发布**: GitHub Release 创建或发布时
- **手动触发**: 支持手动触发并指定自定义标签

#### 1.2 主要功能

##### 多平台构建
```yaml
platforms: linux/amd64,linux/arm64
```
- 支持 x86_64 和 ARM64 架构
- 适配不同的服务器环境
- 自动化多架构镜像构建

##### 智能标签管理
```yaml
tags: |
  type=ref,event=branch          # 分支名作为标签
  type=ref,event=pr              # PR 编号作为标签
  type=semver,pattern={{version}} # 语义化版本标签
  type=raw,value=latest           # latest 标签
```

##### 镜像元数据
- **标题**: EdgeOne Dynamic Origin
- **描述**: Dynamic IPv6 origin management for Tencent Cloud EdgeOne
- **许可证**: MIT
- **供应商**: EdgeOne Dynamic Origin Team

#### 1.3 安全扫描

##### Trivy 漏洞扫描
- 扫描 Docker 镜像中的已知漏洞
- 生成 SARIF 格式报告
- 自动上传到 GitHub Security 标签页

##### SBOM 生成
- 生成软件物料清单 (Software Bill of Materials)
- SPDX-JSON 格式
- 作为构建产物保存

#### 1.4 自动化测试
- 构建完成后自动启动容器测试
- 验证 API 接口可用性
- 测试失败时自动清理资源

### 2. 代码质量检查 (code-quality.yml)

#### 2.1 触发条件
- 推送到 `main`, `master`, `develop` 分支
- 针对这些分支的 Pull Request
- 手动触发

#### 2.2 多版本测试
```yaml
strategy:
  matrix:
    python-version: ["3.12", "3.13"]
```

#### 2.3 代码质量检查项目

##### 代码格式化
- **Black**: Python 代码格式化检查
- **isort**: 导入语句排序检查

##### 代码质量
- **flake8**: 代码风格和语法检查
- **mypy**: 静态类型检查

##### 安全检查
- **bandit**: Python 代码安全漏洞扫描
- **safety**: 依赖包漏洞检查

##### 测试覆盖率
- **pytest**: 单元测试执行
- **coverage**: 代码覆盖率报告
- **codecov**: 覆盖率报告上传

##### Dockerfile 检查
- **hadolint**: Dockerfile 最佳实践检查

## 🚀 使用指南

### 1. 首次配置

#### 1.1 设置 Docker Hub 密钥
在 GitHub 仓库设置中添加以下 Secrets：

```
DOCKER_USERNAME: 你的Docker Hub用户名
DOCKER_PASSWORD: 你的Docker Hub访问令牌
```

#### 1.2 配置环境
1. 进入仓库 Settings → Environments
2. 创建 `production` 环境
3. 添加必要的保护规则（可选）

### 2. 自动构建流程

#### 2.1 开发流程
```bash
# 1. 开发功能
git checkout -b feature/new-feature
# 进行开发...

# 2. 提交代码
git add .
git commit -m "feat: add new feature"
git push origin feature/new-feature

# 3. 创建 Pull Request
# GitHub Actions 会自动运行代码质量检查

# 4. 合并到主分支
# 自动触发 Docker 镜像构建
```

#### 2.2 版本发布流程
```bash
# 1. 创建版本标签
git tag v1.0.0
git push origin v1.0.0

# 2. 创建 GitHub Release
# 在 GitHub 界面创建 Release

# 3. 自动构建和发布
# GitHub Actions 会自动构建并推送镜像
```

### 3. 手动触发构建

#### 3.1 通过 GitHub 界面
1. 进入 Actions 标签页
2. 选择 "Build and Publish Docker Image" 工作流
3. 点击 "Run workflow"
4. 输入自定义标签（可选）
5. 点击 "Run workflow" 确认

#### 3.2 通过 GitHub CLI
```bash
# 使用默认标签
gh workflow run docker-publish.yml

# 使用自定义标签
gh workflow run docker-publish.yml -f tag=custom-tag
```

## 📊 构建产物

### 1. Docker 镜像
- **仓库**: `docker.io/itnotf/edgeone-dynamic-origin`
- **标签**: 
  - `latest`: 最新稳定版本
  - `v1.0.0`: 具体版本号
  - `main`: 主分支最新版本
  - `pr-123`: Pull Request 版本

### 2. 安全报告
- **Trivy 扫描报告**: 上传到 GitHub Security 标签页
- **Bandit 安全报告**: 作为构建产物保存
- **Safety 依赖检查**: 作为构建产物保存

### 3. 代码覆盖率
- **Coverage 报告**: 上传到 Codecov
- **HTML 报告**: 作为构建产物保存

## 🔍 监控和调试

### 1. 构建状态监控

#### 1.1 GitHub 界面
- Actions 标签页查看所有工作流运行状态
- 每个工作流的详细日志和步骤
- 失败时的错误信息和建议

#### 1.2 状态徽章
在 README.md 中添加状态徽章：
```markdown
![Docker Build](https://github.com/username/repo/actions/workflows/docker-publish.yml/badge.svg)
![Code Quality](https://github.com/username/repo/actions/workflows/code-quality.yml/badge.svg)
```

### 2. 常见问题排查

#### 2.1 Docker 构建失败
```bash
# 检查 Dockerfile 语法
docker build -t test .

# 检查依赖文件
cat requirements.txt
```

#### 2.2 代码质量检查失败
```bash
# 本地运行代码格式化
black src/
isort src/

# 本地运行代码检查
flake8 src/
mypy src/
```

#### 2.3 安全扫描问题
```bash
# 本地运行安全检查
bandit -r src/
safety check
```

## ⚙️ 高级配置

### 1. 自定义构建参数

#### 1.1 修改构建参数
在 `docker-publish.yml` 中修改：
```yaml
build-args: |
  BUILDTIME=${{ fromJSON(steps.meta.outputs.json).labels['org.opencontainers.image.created'] }}
  VERSION=${{ fromJSON(steps.meta.outputs.json).labels['org.opencontainers.image.version'] }}
  CUSTOM_ARG=value
```

#### 1.2 添加环境变量
```yaml
env:
  CUSTOM_ENV: value
  REGISTRY: docker.io
```

### 2. 缓存优化

#### 2.1 Docker 构建缓存
```yaml
cache-from: type=gha
cache-to: type=gha,mode=max
```

#### 2.2 Python 依赖缓存
```yaml
- uses: actions/setup-python@v4
  with:
    cache: 'pip'
```

### 3. 并行构建

#### 3.1 矩阵构建
```yaml
strategy:
  matrix:
    platform: [linux/amd64, linux/arm64]
```

#### 3.2 条件执行
```yaml
if: github.event_name != 'pull_request'
```

## 🔒 安全最佳实践

### 1. 密钥管理
- 使用 GitHub Secrets 存储敏感信息
- 定期轮换访问令牌
- 使用最小权限原则

### 2. 镜像安全
- 定期更新基础镜像
- 扫描已知漏洞
- 使用非 root 用户运行

### 3. 工作流安全
- 限制工作流权限
- 验证第三方 Actions
- 使用固定版本的 Actions

## 📈 性能优化

### 1. 构建时间优化
- 使用构建缓存
- 并行执行步骤
- 优化 Dockerfile 层级

### 2. 资源使用优化
- 合理设置超时时间
- 及时清理临时文件
- 使用轻量级基础镜像

## 🔄 维护和更新

### 1. 定期维护任务
- 更新 GitHub Actions 版本
- 更新依赖包版本
- 检查安全漏洞报告

### 2. 工作流版本管理
- 使用语义化版本控制
- 记录重要变更
- 测试新版本工作流

## 📚 参考资源

### 1. 官方文档
- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [Docker Build Push Action](https://github.com/docker/build-push-action)
- [Docker Metadata Action](https://github.com/docker/metadata-action)

### 2. 最佳实践
- [GitHub Actions 最佳实践](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions)
- [Docker 最佳实践](https://docs.docker.com/develop/dev-best-practices/)

### 3. 工具文档
- [Trivy 漏洞扫描器](https://trivy.dev/)
- [Hadolint Dockerfile 检查器](https://github.com/hadolint/hadolint)
- [Codecov 代码覆盖率](https://codecov.io/)

## 📝 总结

本项目的 GitHub Actions 工作流提供了完整的 CI/CD 解决方案，包括：

1. **自动化构建**: 多平台 Docker 镜像自动构建和发布
2. **质量保证**: 全面的代码质量检查和测试
3. **安全扫描**: 漏洞扫描和安全报告
4. **智能部署**: 基于分支和标签的智能部署策略
5. **监控诊断**: 完善的日志记录和状态监控

这些自动化流程大大提高了开发效率，确保了代码质量，并为生产环境提供了可靠的部署保障。