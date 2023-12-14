import { FULL } from '../common/constant/global'
import { BookQuery, BookQueryALlChapter, BookQueryBooks, BookQueryContent, BookQueryHistory, BookQueryShelf } from '../common/dao/BookDao'
import { RequestPost } from '../common/dao/http'
import { Book } from '../common/model/Book'
import { DataResult } from '../common/model/Result'
import { GetBook } from '../common/utils/BookUtils'
import { BookCity } from '../views/BookCity'
import { BookShelf } from '../views/BookShelf'
import { Category } from '../views/Category'
@Entry
@Component
struct Index {
  @State curIndex: number = 0

  @State type_shelf: string = "书架"
  @State books_shelf: Book[] = []
  @State msg_category: string[] = []
  @State msg_city: string[] = []
  @State books_category: Book[] = []
  @State books_city: Book[] = []

  async onPageShow() {

    if(this.curIndex  === 2) {
      this.query_shelf()
      return
    }

    let books: Book[];
    let msg: string[];

    if (this.curIndex == 0) {
      books = this.books_city;
      msg = this.msg_city;
    } else if(this.curIndex==1){
      books = this.books_category;
      msg = this.msg_category;
    }

    const promises = books.map((book, i) => {
      return new Promise<void>((resolve, reject) => {
        BookQuery(book, (ret: Book) => {
          books[i] = ret;
          GetBook(books[i], (ret: Book) => {
            books[i] = ret;
            msg[i] = books[i].bookIsInShelf ? "已在书架" : "加入书架";
            resolve();
          });
        });
      });
    });
    await Promise.all(promises);

    if (this.curIndex == 0) {
      this.books_city = books;
      this.msg_city = msg;
    } else if(this.curIndex == 1){
      this.books_category = books;
      this.msg_category = msg;
    }
  }
  query_shelf(){
    if(this.type_shelf === "书架") {
      BookQueryShelf(async (ret: Book[])=>{
        this.books_shelf = ret
        const promises = this.books_shelf.map((book, i) => {
          return new Promise<void>((resolve, reject) => {
            BookQuery(book, (ret: Book) => {
              this.books_shelf[i] = ret;
              GetBook(this.books_shelf[i], (ret: Book) => {
                this.books_shelf[i] = ret;
                resolve();
              });
            });
          });
        });
        await Promise.all(promises);
      })
    } else {
      BookQueryHistory(async (ret: Book[])=>{
        this.books_shelf = ret
        const promises = this.books_shelf.map((book, i) => {
          return new Promise<void>((resolve, reject) => {
            BookQuery(book, (ret: Book) => {
              this.books_shelf[i] = ret;
              GetBook(this.books_shelf[i], (ret: Book) => {
                this.books_shelf[i] = ret;
                resolve();
              });
            });
          });
        });
        await Promise.all(promises);
      })
    }
  }

  build() {
    Row() {
      Column() {
        Tabs({ barPosition: BarPosition.End }) {
          TabContent() {BookCity({msg: $msg_city, books: $books_city})}
          .tabBar('书城')

          TabContent() {Category({msg: $msg_category,  books: $books_category})}
          .tabBar('分类')

          TabContent() {BookShelf({books:$books_shelf, type: $type_shelf})}
          .tabBar('书架')
        }
        .onChange((index: number)=>{
          if(index == 2) {this.query_shelf()}
          this.curIndex = index
        })
      }
      .width(FULL)
    }
    .height(FULL)
  }

}