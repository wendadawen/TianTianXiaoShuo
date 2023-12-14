
import { Book } from '../model/Book';
import call from '@ohos.telephony.call';

export function GetBook(book: Book, callback?: Function){
  book.bookUpdateTime = new Date(book.bookUpdateTime)
  book.bookName = book.bookName as string
  book.bookAuthor = book.bookAuthor as string
  book.bookDetail = book.bookDetail as string
  book.bookStatus = book.bookStatus as string
  book.bookImage = book.bookImage as string
  book.bookRenqi = book.bookRenqi as string
  book.bookTags = book.bookTags as string
  book.bookLatestChapter = book.bookLatestChapter as string
  book.bookAllChapterNum = book.bookAllChapterNum as number
  book.bookPage = book.bookPage as string
  book.bookReadChapter = book.bookReadChapter as number
  book.bookIsInShelf = book.bookIsInShelf as boolean
  callback(book)
}