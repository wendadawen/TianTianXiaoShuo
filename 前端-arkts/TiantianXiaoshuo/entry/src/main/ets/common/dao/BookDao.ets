
import { Book } from '../model/Book';
import { DataResult } from '../model/Result';
import BookTable from '../Rdb/BookTable';
import { GetBook } from '../utils/BookUtils';
import { RequestPost } from './http';

export const host: string = "http://192.168.24.1:10086"
const bookTable: BookTable= new BookTable()

/****************************后端数据库*******************************/
// 给你bookName bookPage bookReadChapter, 后端查询该章节的内容和标题
export function BookQueryContent(book: Book, callback?: Function){
  RequestPost(host + "/book/chapter/content", book, (ret: DataResult)=>{
    var info = ret.data as {
      title: string,
      content: string
    }
    if(callback) callback(info.title, info.content)
  })
}

// 给你bookName bookPage 后端查询该书的所有章节
export function BookQueryALlChapter(book: Book, callback?: Function) {
  RequestPost(host + "/book/chapter/all", book, (ret: DataResult)=>{
    let chapters: string[] = ret.data as string[]
    if(callback)callback(chapters)
  })
}

// 给你size, type，后端随机type类型返回size本书
export function BookQueryBooks(size: number, type: string, callback?: Function) {
  RequestPost(host + "/book/get/books", {
    size: size,
    type: type,
  }, (ret: DataResult)=>{
    let books: Book[] = ret.data as Book[]
    for (let index = 0; index < books.length; index++) {
      GetBook(books[index], (ret: Book)=>{
        books[index] = ret
        books[index].bookReadChapter = 1
        books[index].bookIsInShelf = false
      })
    }
    if(callback)callback(books)
  })
}
// 给你size，offset,key, 返回搜索结果
export function BookSearch(size: number, offset: number, key: string, callback?: Function) {
  RequestPost(host + "/book/search", {
    size: size,
    offset: offset,
    key: key
  }, (ret: DataResult)=>{
    let books: Book[] = ret.data as Book[]
    for (let index = 0; index < books.length; index++) {
      GetBook(books[index], (ret: Book)=>{
        books[index] = ret
        books[index].bookReadChapter = 1
        books[index].bookIsInShelf = false
      })
    }
    if(callback)callback(books)
  })
}

/****************************手机端数据库*******************************/
// 查询单个书籍的信息
export function BookQuery(book: Book, callback?: Function) {
  bookTable.querySignal(book, (ret: Book[])=>{
    if(ret.length === 0) {
      if(callback)callback(book)
    } else {
      if(callback)callback(ret[0])
    }
    return
  })
}
// 更新
export function BookUpdate(book: Book, callback?: Function) {
  bookTable.querySignal(book, (ret: Book[])=>{
    if(ret.length === 0) {
      bookTable.insertData(book, ()=>{if(callback)callback()})
    } else {
      bookTable.updateData(book, ()=>{if(callback)callback()})
    }
    return
  })
}
// 插入
export function BookInsert(book: Book, callback?: Function) {
  bookTable.querySignal(book, (ret: Book[])=>{
    if(ret.length === 0) {
      bookTable.insertData(book, ()=>{if(callback)callback()})
    } else {
      if(callback) callback()
    }
    return
  })
}
// 查询在书架上的
export function BookQueryShelf(callback?: Function) {
  if(callback)bookTable.queryShelf(callback)
}

export function BookQueryHistory(callback?: Function) {
  if(callback)bookTable.queryHistory(callback)
}
