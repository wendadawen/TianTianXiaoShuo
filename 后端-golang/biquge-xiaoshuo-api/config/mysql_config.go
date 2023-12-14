package config

import "biquge-xiaoshuo-api/config/setting"

const DriverName = "mysql"

type mysqlConfig struct {
	Host         string
	Port         string
	Password     string
	UserName     string
	DatabaseName string
}

var MysqlConfig = mysqlConfig{
	Host:         setting.MysqlConfig.GetString("host"),
	Port:         setting.MysqlConfig.GetString("port"),
	Password:     setting.MysqlConfig.GetString("password"),
	UserName:     setting.MysqlConfig.GetString("userName"),
	DatabaseName: setting.MysqlConfig.GetString("databaseName"),
}
