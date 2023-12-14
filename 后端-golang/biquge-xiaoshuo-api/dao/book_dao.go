package dao

import (
	"biquge-xiaoshuo-api/dao/db"
	"biquge-xiaoshuo-api/dao/model"
	"log"
)

var engin = db.InstanceMaster()

func BookInsert(book *model.Book) {
	_, err := engin.Insert(book)
	if err != nil {
		log.Println("BookDao Insert Error: ", err)
		return
	}
}

func BookQuery(bookName string) bool {
	book := &model.Book{BookName: bookName}
	get, _ := engin.Get(book)
	if get {
		return true
	}
	return false
}

func BookQueryBooksByType(Size int, Type string) []model.Book {
	books := make([]model.Book, 0)
	err := engin.SQL(`SELECT * FROM book WHERE book_tags=? ORDER BY RAND() LIMIT ?`, Type, Size).Find(&books)
	if err != nil {
		log.Printf("BookDao QueryBooks Error: %+v\n", err)
		return nil
	}
	return books
}

func BookQueryBooks(Size int) []model.Book {
	books := make([]model.Book, 0)
	err := engin.SQL(`SELECT * FROM book ORDER BY RAND() LIMIT ?`, Size).Find(&books)
	if err != nil {
		log.Printf("BookDao QueryBooks Error: %+v\n", err)
		return nil
	}
	return books
}

func BookSearch(key string, size int, offset int) []model.Book {
	books := make([]model.Book, 0)
	key = "%" + key + "%"
	err := engin.SQL(`SELECT * FROM book WHERE book_author LIKE ? OR book_name LIKE ? LIMIT ? OFFSET ?`, key, key,
		size, offset).Find(&books)
	if err != nil {
		log.Printf("BookDao Search Error: %+v\n", err)
		return nil
	}
	return books
}
