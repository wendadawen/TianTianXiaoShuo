package main

import (
	"biquge-xiaoshuo-api/dao"
	"biquge-xiaoshuo-api/dao/model"
	R "biqugeSpider/tool/R"
	"fmt"
	"github.com/spf13/cast"
	"log"
	"os"
	"strings"
	"sync"
	"time"
)

var mutex = sync.Mutex{}

func main() {
	endNum := 1391 // 1391
	host := "https://www.biqugecn.com/"
	const layout = "2006-01-02 15:04:05"
	// 日志文件
	file, err := os.OpenFile("logfile.txt", os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()

	// 将日志输出目标设置为文件
	log.SetOutput(file)
	group := &sync.WaitGroup{}          // 控制主线程和协程一起结束
	semaphore := make(chan struct{}, 3) // 并向数，不能设置太大了，服务器容易崩

	//group := sync.WaitGroup{}
	for i := 1000; i <= endNum; i++ {
		group.Add(1)
		semaphore <- struct{}{}
		go func(index int) {
			defer func() { <-semaphore }()
			defer group.Done()
			addr := host + "toptoptime/" + cast.ToString(index) + ".html"
			html := R.Get(addr)
			html = R.ConvertEncodingToUTF8(html)
			matches := R.FindAll(html, `<tr><td class="hidden-xs">(.*?)</td><td><a href="(.*?)" target="_blank">(.*?)</a></td><td class="hidden-xs"><a href=".*?" target="_blank">(.*?)</a></td><td>(.*?)</td><td>(.*?)</td></tr>`)
			for _, match := range matches {
				func() {
					defer func() {
						if err := recover(); err != nil {
							//s := string(debug.Stack())
							log.Printf("%s, %+v\n", match[3], err)
						}
					}()
					category := match[1]
					addr = match[2]
					name := match[3]
					latest := match[4]
					author := match[5]
					updateTime := match[6]
					updatetime, _ := time.Parse(layout, updateTime)
					fmt.Printf("%s %s %s %s %s %s ", category, addr, name, latest, author, updateTime)
					if dao.BookQuery(name) {
						return
					}
					html = R.Get(addr)
					html = R.ConvertEncodingToUTF8(html)
					imageUrl := R.FindSignal(html, `<img class="img-thumbnail".*?src="(.*?)"`)[1] // imageUrl
					info2 := R.FindSignal(html, `人气：(.*?)</span><.*?>(.*?)</span>`)               // renqi, status
					detail := R.FindSignal(html, `<p class="text-muted" id="bookIntro".*?/>(.*?)</p>`)[1]
					detail = strings.ReplaceAll(detail, " ", "")
					detail = strings.ReplaceAll(detail, "&nbsp;", " ")
					detail = strings.ReplaceAll(detail, "<br/>", "\n")
					html = R.FindSignal(html, `<div class="panel panel-default" id="list-chapterAll">(.*?)</html>`)[1]
					chapters := R.FindAll(html, `<dd class="col-md-3"><a href="(.*?)".*?</a></dd>`)
					fmt.Printf("url: %s, renqi: %s, status: %s, detail: %s, size: %d \n", imageUrl, info2[1], info2[2], detail, len(chapters))
					book := &model.Book{
						BookName:          name,
						BookAuthor:        author,
						BookDetail:        detail,
						BookImage:         imageUrl,
						BookLatestChapter: latest,
						BookRenqi:         info2[1],
						BookStatus:        info2[2],
						BookTags:          category,
						BookUpdateTime:    updatetime,
						BookPage:          addr,
						BookAllChapterNum: len(chapters),
					}
					//mutex.Lock()
					dao.BookInsert(book)
					//mutex.Unlock()
				}()
			}
		}(i)
	}
	group.Wait()

	//addr := "https://www.biqugecn.com/book/807/"
	//html := R.Get(addr)
	////R.SaveFileFromString(html, "./html.html")
	//html = R.ConvertEncodingToUTF8(html)
	//html = R.FindSignal(html, `<div class="panel panel-default" id="list-chapterAll">(.*?)</html>`)[1]
	//println(html)
	//chapters := R.FindAll(html, `<dd class="col-md-3"><a href="(.*?)".*?</a></dd>`)
	//for i := range chapters {
	//	println(chapters[i][0], chapters[i][1])
	//}
	//imageUrl := R.FindSignal(html, `<img class="img-thumbnail".*?src="(.*?)"`)[1] // imageUrl
	//info2 := R.FindSignal(html, `人气：(.*?)</span><.*?>(.*?)</span>`)               // renqi, status
	//detail := R.FindSignal(html, `<p class="text-muted" id="bookIntro".*?/>(.*?)</p>`)[1]
	//detail = strings.ReplaceAll(detail, " ", "")
	//detail = strings.ReplaceAll(detail, "&nbsp;", " ")
	//detail = strings.ReplaceAll(detail, "<br/>", "\n")
	//fmt.Printf("url: %s, renqi: %s, status: %s, detail: %s\n", imageUrl, info2[1], info2[2], detail)
}
