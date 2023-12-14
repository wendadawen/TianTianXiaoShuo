package controller

import (
	"github.com/kataras/iris/v12"
)

type BookController struct {
	Ctx iris.Context
}

func NewBookController() *BookController {
	return &BookController{}
}

//
//// GetChapter @summary 获取这个章节的内容
//// @Success 200 {object} result.Result
//// @tags 书籍/book
//// @Router /book/all/chapter [get]
//// @param bookName formData string true "书名" Default(斗罗大陆)
//// @param chapter formData string true "第几章" Default(第一章)
//func (this *BookController) GetChapter() result.Result {
//	this.Ctx.JSON(result.DataResult("hi"))
//	return result.EmptyResult()
//}
