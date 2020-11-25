# 告诉 linux 系统这是一个 shell 脚本
#!/bin/sh
# 构想 https://gist.github.com/motemen/8595451
# 基于 https://github.com/eldarlabs/ghpages-deploy-script/blob/master/scripts/deploy-ghpages.sh
# usage: push-gh-pages DIRECTORY # DIRECTORY is where GitHub pages contents are in (eg. build)
# LICENSE: Public Domain

# abort the script if there is a non-zero error
# 没有收到一个非零的数值就退出 shell 脚本执行
set -e

# 打印当前的工作路径
pwd
# 设置远程仓库地址
remote=$(git config remote.origin.url)
# 打印仓库地址
echo 'remote is：'$remote

# siteSource="$1"

if [ ! -d "$siteSource" ]; then
    echo "Usage: $0 <site source dir>"
    exit 1
fi

# 新建一个发布的目录
mkdir gh-pages-branch
cd gh-pages-branch
# 创建的一个新的仓库
# 设置发布的用户名与邮箱
git config --global user.email "$GH_EMAIL" >/dev/null 2>&1
git config --global user.name "$GH_NAME" >/dev/null 2>&1
# 初始化一个临时的 git 仓库 并且 拉取远程的代码
git init
git remote add --fetch origin "$remote"

# 切换到 gh-pages 分支，gh-pages 分支是 github page 用的
if git rev-parse --verify origin/gh-pages >/dev/null 2>&1; then
    git checkout gh-pages
    # 当前存在这个分支，删除旧的文件内容
    # Note: this explodes if there aren't any, so moving it here for now
    git rm -rf .
else
    git checkout --orphan gh-pages
fi

ls -a

# 把构建好的文件目录给拷贝进来
cp -a "../${siteSource}/." .

# 把所有的文件添加到 git
git add -A
# 添加一条提交内容
git commit --allow-empty -m "Deploy to GitHub pages [ci skip]"
# 推送文件
git push --force --quiet origin gh-pages >/dev/null 2>&1

# 资源回收，删除临时分支与目录
cd ..
rm -rf gh-pages-branch

# 完成发布
echo "Finished Deployment!"
