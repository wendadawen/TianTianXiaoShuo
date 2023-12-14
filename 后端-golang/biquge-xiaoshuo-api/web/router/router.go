package router

import (
	"biquge-xiaoshuo-api/web/controller"
	"github.com/kataras/iris/v12"
	"github.com/kataras/iris/v12/mvc"
)

func InitRouter(app *iris.Application) {
	mvc.New(app.Party("/book")).Handle(controller.NewBookController())
}
