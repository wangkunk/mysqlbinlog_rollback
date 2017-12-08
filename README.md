# mysqlbinlog_rollback
回滚mysqlDML操作的shell脚本,可以根据时间点或者position回滚对单个表的删除或更新操作。
条件：
1.mysqlbinlog打开且不为Statement模式
2.要回滚的表字段没有做过更改

QQ:863879392
