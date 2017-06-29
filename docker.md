##**查看docker版本信息**

```
#docker version
#docker -v
#docker info
```
##**image镜像操作命令**

```
#docker search image_name //检索image
#docker pull image_name   //下载镜像
#docker images            //列出本地镜像  -a, --all=false Show all images; --no-trunc=false Don't truncate output; -q, --quiet=false Only show numeric IDs
//删除一个或者多个镜像; -f, --force=false Force; --no-prune=false Do not delete untagged parents
#docker rmi image_name
//显示一个镜像的历史; --no-trunc=false Don't truncate output; -q, --quiet=false Only show numeric IDs
#docker history image_name
```
##**容器操作**

```
# 在容器中运行"echo"命令，输出"hello word"
$docker run image_name echo "hello word"

# 交互式进入容器中
$docker run -i -t image_name /bin/bash

# 后台启动镜像 并更改镜像名字
$docker run -d --name myImage centos

# 在容器中安装新的程序
$docker run image_name yum install -y app_name

# 列出当前所有正在运行的container
$docker ps
# 列出所有的container
$docker ps -a
# 列出最近一次启动的container
$docker ps -l

# 保存对容器的修改; -a, --author="" Author; -m, --message="" Commit message
$docker commit ID new_image_name


# 删除所有容器
$docker rm `docker ps -a -q`

# 删除单个容器; -f, --force=false; -l, --link=false Remove the specified link and not the underlying container; -v, --volumes=false Remove the volumes associated to the container
$docker rm Name/ID

# 停止、启动、杀死一个容器
$docker stop Name/ID
$docker start Name/ID
$docker kill Name/ID

# 从一个容器中取日志; -f, --follow=false Follow log output; -t, --timestamps=false Show timestamps
$docker logs Name/ID

# 列出一个容器里面被改变的文件或者目录，list列表会显示出三种事件，A 增加的，D 删除的，C 被改变的
$docker diff Name/ID

# 显示一个运行的容器里面的进程信息
$docker top Name/ID

# 从容器里面拷贝文件/目录到本地一个路径
$docker cp Name:/container_path to_path
$docker cp ID:/container_path to_path

# 重启一个正在运行的容器; -t, --time=10 Number of seconds to try to stop for before killing the container, Default=10
$docker restart Name/ID

# 附加到一个运行的容器上面; --no-stdin=false Do not attach stdin; --sig-proxy=true Proxify all received signal to the process
$docker attach ID

#访问另一个容器的命名空间 进入另一个容器
#安装Linux工具包
$ yum install -y util-linux
#获取容器的Pid
$docker inspect --format "{{.State.Pid}}" containerName
#进入容器
$ nsenter --target Pid --mount --uts --ipc --net --pid

#容器网络配置
#随机生成container到host端口映射
$docker run -d -P --name myNginx nginx
#指定特定端口 将container 80到host91端口的映射
$docker run -d -p 91:80 --name myNginx imageName
# -p ip: hostPort:containerPosrt
$docker ps -l
```

##**docker数据管理**

```
# -v 绑定挂载一个数据卷 -h 给容器指定一个主机名
$docker run -it --name volume-test1 -h nginx -v /data/ imageName

#或着手动设置映射
$docker run -it --name volume-test1 -h nginx -v /opt:/opt imageName

#挂载另一容器， 另一容器volume-test2（即使容器已经停掉）来做volume-test1的专门的存储
$docker run -it --name volume-test1 -h nginx --volumes-from volume-test2 imageName

#显示数据卷到host主机的映射关系
$docker inspect -f {{.Volumes}} volume-test1
```
