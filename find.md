1. 按文件名搜索。 
搜索当前目录下所有的以txt结尾的文件。第二个命令用了 -exec 参数，可以在对查找的所有文件执行一种操作。注意格式，空格和;一个都不能少。-name 的参数可以用正则表达式，例如第二个例子

find ./* -name "*.txt"
find ./* -name "[ab]*.py"
find ./* -name "*.pyc" -exec rm {} \;

2. 按修改时间查找 
查找当前目录下当天修改过的文件。-1 表示一天前修改过的文件。-2表示前两天。find ./* -mtime n n表示，对文件数据的最近一次修改是在 n*24 小时之前。+n 指n天以前，-n指n天以内(对 -mmin 是指n分钟), n 表示第n天，他们的含义都是不同的，注意区分。

find ./* -mtime  60 -type f -print 
find ./* -mmin -60 -type f -print
find ./* -mmin +60 -type f -print

3. 文件状态改变 
和 上个参数相比，基本道理都是一样的，只不过这个参数的含义是文件的权限被修改。改内容和改文件的权限是不一样的，这里指的是更改的是文件inode的数据，比如文件的权限，所属人等等信息。cmin 表示近60分钟内被改过权限，ctime 表示近几天内被修改过。

find ./* -cmin +60 -type f -print
find ./* -ctime -60 -type f -print

4 
按照文件的所属group和 所属user 来查找-user 和 -nouser 最后一个命令找出当前已经被删除的系统用户的所有文件， - group 和 - nogroup 的功能类似。

find ./* -user fox
find ./* -nouser

5 
find 避开某个目录,避开多个目录。其中 -a 表示 and 的意思，-o 表示or 的意思。

find test -path "test/test4" -prune -o -print
find test \( -path test/test4 -o -path test/test3 \) -prune -o -print 
find . \( -path ./modules -o -path ./framework -o -path ./utils -o -path ./config \) -prune -o -name "Bigger.*" -print

6 
-perm 选项 指文件的访问权限

find -perm 755 -print

7 
实用inode 来查找文件编号。可以如下面所示在find命令中指定inode编号。在此，find命令用inode编号重命名了一个文件。你也可以通过rm来删除那个特殊的文件。

ls -i1 test*
16187429 test-file-name
16187430 test-file-name
find -inum 16187430 -exec mv {} new-test-file-name \;

8 
找出当前目录下最大的5个文件

find . -type f -exec ls -s {} \; | sort -n -r | head -5

9 
下面的命令删除大于100M的*.zip文件。

find / -type f -name *.zip -size +100M -exec rm -i {} \;