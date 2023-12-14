package config

import "biquge-xiaoshuo-api/config/setting"

type serverConfig struct {
	Port string
}

var ServerConfig = serverConfig{
	Port: setting.ServerConfig.GetString("port"),
}
