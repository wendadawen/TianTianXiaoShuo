package main

import (
	"biquge-xiaoshuo-api/config"
	"biquge-xiaoshuo-api/dao"
	"biquge-xiaoshuo-api/tool/R"
	"biquge-xiaoshuo-api/web/result"
	"biquge-xiaoshuo-api/web/router"
	"github.com/iris-contrib/swagger/v12"
	"github.com/iris-contrib/swagger/v12/swaggerFiles"
	"github.com/kataras/iris/v12"
	"github.com/kataras/iris/v12/context"
	"log"
	"net/http"
	"os"
	"strings"
	"time"
)

// 使用 swag init生成
// @title template模板
// @version 1.0
// @description Go 语言编程之旅：一起用 Go 做项目
func main() {
	app := iris.Default()
	app.Configure(iris.WithOptimizations)
	router.InitRouter(app)
	file, _ := os.OpenFile("output.log", os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	defer file.Close()
	log.SetOutput(file)

	app.Get("/swagger/{any:path}", swagger.CustomWrapHandler(&swagger.Config{
		URL: "http://localhost:" + config.ServerConfig.Port + "/swagger/doc.json",
	}, swaggerFiles.Handler))

	app.Post("/book/chapter/content", func(ctx *context.Context) {
		log.Printf("API:/book/chapter/content Be Called\n")
		defer func(ctx *context.Context) {
			if err := recover(); err != nil {
				log.Printf("API:/book/chapter/content ERROR: %+v\n", err)
				ctx.JSON(result.FailedResult())
				return
			}
		}(ctx)
		book := struct {
			BookName        string
			BookPage        string
			BookReadChapter int
		}{}
		_ = ctx.ReadJSON(&book)
		addr := book.BookPage
		index := book.BookReadChapter

		html := R.Get(addr)
		html = R.ConvertEncodingToUTF8(html)
		html = R.FindSignal(html, `<div class="panel panel-default" id="list-chapterAll">(.*?)</html>`)[1]
		chapters := R.FindAll(html, `<dd class="col-md-3"><a href="(.*?)" title="(.*?)".*?</a></dd>`)
		addr = book.BookPage + chapters[index-1][1]
		title := chapters[index-1][2]
		html = R.Get(addr)
		html = R.ConvertEncodingToUTF8(html)
		content := ""
		ret := R.FindSignal(html, `<div.*?id="htmlContent".*?>(.*?)</div>`)
		for true {
			content += ret[1]
			if !strings.Contains(ret[1], "本章未完，点击下一页继续阅读") {
				break
			}
			ret = R.FindSignal(html, `<a id="linkNext" class="btn btn-default" href="(.*?)">下一页</a>`)
			addr = book.BookPage + ret[1]
			html = R.Get(addr)
			html = R.ConvertEncodingToUTF8(html)
			ret = R.FindSignal(html, `<div.*?id="htmlContent".*?>(.*?)</div>`)
		}
		content = strings.ReplaceAll(content, `<p class="text-danger text-center mg0">本章未完，点击下一页继续阅读</p>`, "")
		content = strings.ReplaceAll(content, `笔趣阁 www.biqugecn.com，最快更新<a href="`+book.BookPage+`">`+book.BookName+`</a>最新章节！`, "")
		content = strings.ReplaceAll(content, `<br>`, "\n")
		content = strings.ReplaceAll(content, `<br/>`, "\n")
		content = strings.ReplaceAll(content, `&nbsp;`, " ")

		//println(content)
		//println(title)
		//println("------------------------")
		err := ctx.JSON(result.DataResult(struct {
			Title   string `json:"title"`
			Content string `json:"content"`
		}{
			Title:   title,
			Content: content,
		}))
		if err != nil {
			return
		}
	})

	app.Post("/book/chapter/all", func(ctx *context.Context) {
		log.Printf("API:/book/chapter/all Be Called\n")
		defer func(ctx *context.Context) {
			if err := recover(); err != nil {
				log.Printf("API:/book/chapter/all ERROR: %+v\n", err)
				ctx.JSON(result.FailedResult())
				return
			}
		}(ctx)
		book := struct {
			BookName string
			BookPage string
		}{}
		_ = ctx.ReadJSON(&book)
		addr := book.BookPage
		html := R.Get(addr)
		html = R.ConvertEncodingToUTF8(html)
		html = R.FindSignal(html, `<div class="panel panel-default" id="list-chapterAll">(.*?)</html>`)[1]
		chapters := R.FindAll(html, `<dd class="col-md-3"><a href=".*?" title="(.*?)".*?</a></dd>`)
		ret := []string{}
		for i := range chapters {
			ret = append(ret, chapters[i][1])
			//print(chapters[i][1] + " ")
		}
		//println()
		//marshal, err := json.Marshal(ret)
		//if err != nil {
		//	return
		//}
		//println(string(marshal))
		ctx.JSON(result.DataResult(ret))
	})

	app.Post("/book/get/books", func(ctx *context.Context) {
		log.Printf("API:/book/get/books Be Called\n")
		info := struct {
			Size int    `json:"size"`
			Type string `json:"type"`
		}{}
		_ = ctx.ReadJSON(&info)
		if info.Type != "全部" {
			ctx.JSON(result.DataResult(dao.BookQueryBooksByType(info.Size, info.Type)))
		} else {
			ctx.JSON(result.DataResult(dao.BookQueryBooks(info.Size)))
		}

	})

	app.Post("/book/search", func(ctx *context.Context) {
		log.Printf("API:/book/search Be Called\n")
		info := struct {
			Offset int    `json:"offset"`
			Size   int    `json:"size"`
			Key    string `json:"key"`
		}{}
		_ = ctx.ReadJSON(&info)
		ctx.JSON(result.DataResult(dao.BookSearch(info.Key, info.Size, info.Offset)))
	})

	srv := &http.Server{
		ReadTimeout:  60 * time.Second,
		WriteTimeout: 60 * time.Second,
		Addr:         ":" + config.ServerConfig.Port,
	}
	_ = app.Run(iris.Server(srv))
}
