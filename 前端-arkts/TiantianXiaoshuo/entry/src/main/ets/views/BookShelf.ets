
import { BackgroundColor, BlackColor, ContentColor, FULL, GreyColor } from '../common/constant/global'
import { BookUpdate, BookQueryHistory, BookQueryShelf, BookQuery } from '../common/dao/BookDao'
import { Book } from '../common/model/Book'
import { BookForShelf } from './component/BookForShelf'
import router from '@ohos.router'
import { GetBook } from '../common/utils/BookUtils'

@Component
export struct BookShelf {
  @Link type: string;
  @Link books: Book[];

  @Builder itemEnd(index: number) {
    Column(){
      Image(this.type==="书架"?$r('app.media.delete'):$r('app.media.addShelf'))
        .objectFit(ImageFit.Contain)
        .width("40%")
      Text(this.type==="书架"?"删除书籍":"加入书架")
        .textAlign(TextAlign.Center)
        .width(FULL)
    }
    .justifyContent(FlexAlign.Center)
    .width("20%")
    .height(FULL)
    .onClick(() => {
      if(this.type==="书架") {
        this.books[index].bookIsInShelf = false
      } else {
        this.books[index].bookIsInShelf = true
      }
      BookUpdate(this.books[index], ()=>{
        this.query()
      })
    })

  }
  query(){
    if(this.type === "书架") {
      BookQueryShelf(async (ret: Book[])=>{
        this.books = ret
        const promises = this.books.map((book, i) => {
          return new Promise<void>((resolve, reject) => {
            BookQuery(book, (ret: Book) => {
              this.books[i] = ret;
              GetBook(this.books[i], (ret: Book) => {
                this.books[i] = ret;
                resolve();
              });
            });
          });
        });
        await Promise.all(promises);
      })
    } else {
      BookQueryHistory(async (ret: Book[])=>{
        this.books = ret
        const promises = this.books.map((book, i) => {
          return new Promise<void>((resolve, reject) => {
            BookQuery(book, (ret: Book) => {
              this.books[i] = ret;
              GetBook(this.books[i], (ret: Book) => {
                this.books[i] = ret;
                resolve();
              });
            });
          });
        });
        await Promise.all(promises);
      })
    }
  }

  build(){
    Column(){
      Row(){
        Text("书架")
          .textAlign(TextAlign.Center)
          .width("25%")
          .height(FULL)
          .fontColor(this.type==="书架"?BlackColor:GreyColor)
          .onClick(()=>{
            this.type="书架"
            this.query()
          })

        Text("历史")
          .width("25%")
          .textAlign(TextAlign.Center)
          .height(FULL)
          .fontColor(this.type==="历史"?BlackColor:GreyColor)
          .onClick(()=>{
            this.type="历史"
            this.query()
          })
      }
      .justifyContent(FlexAlign.Start)
      .borderRadius(20)
      .width(FULL)
      .height("10%")
      .backgroundColor(ContentColor)
      .margin({top: 12})

      Row(){
        Text("    共" + this.books.length+"本")
          .fontColor(GreyColor)
          .width(FULL)
          .height(FULL)
      }
      .width(FULL)
      .height("5%")

      Column(){
        List({space: 20}){
          ForEach(this.books, (book: Book, index: number)=>{
            ListItem(){
              BookForShelf({book: book, index: index+1})
            }
            .height("20%")
            .width(FULL)
            .swipeAction({ end: this.itemEnd.bind(this, index) })
            .onClick(()=>{
              router.pushUrl({
                url: 'pages/BookCatalog',
                params: book
              })
            })
          }, (item: Book)=>item.bookName+item.bookReadChapter)
        }
        .margin({bottom: 12, left: 12, right: 12})
        .padding(12)
        .width("90%")
        .height("90%")
        .backgroundColor(ContentColor)
        .borderRadius(20)
      }
      .width(FULL)
      .height("85%")

    }
    .height(FULL)
    .width(FULL)
    .backgroundColor(BackgroundColor)
  }
}