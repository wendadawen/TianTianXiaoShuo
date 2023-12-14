package model

import (
	"biquge-xiaoshuo-api/dao/db"
	"log"
	"time"
)

func init() {
	engine := db.InstanceMaster()
	err := engine.CreateTables(&Book{})
	if err != nil {
		log.Fatalln("CreatTable Book Error: ", err)
	}
}

type Book struct {
	BookName          string    `xorm:"not null pk comment('书名') unique VARCHAR(255)" json:"bookName"`
	BookAuthor        string    `xorm:"comment('作者') VARCHAR(255)" json:"bookAuthor"`
	BookDetail        string    `xorm:"comment('详细') TEXT" json:"bookDetail"`
	BookUpdateTime    time.Time `xorm:"comment('最后更新时间') DATETIME" json:"bookUpdateTime"`
	BookStatus        string    `xorm:"comment('状态') VARCHAR(255)" json:"bookStatus"`
	BookImage         string    `xorm:"comment('图片url') VARCHAR(255)" json:"bookImage"`
	BookRenqi         string    `xorm:"comment('人气') VARCHAR(255)" json:"bookRenqi"`
	BookTags          string    `xorm:"comment('分类') VARCHAR(255)" json:"bookTags"`
	BookLatestChapter string    `xorm:"comment('最新章节') VARCHAR(255)" json:"bookLatestChapter"`
	BookAllChapterNum int       `xorm:"comment('所有的章节数量') VARCHAR(255)" json:"bookAllChapterNum"`
	BookPage          string    `xorm:"comment('书本的url') VARCHAR(255)" json:"bookPage"`
}
