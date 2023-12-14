
import { TYPES } from '../common/constant/categoryConstant'
import { BackgroundColor, BlackColor, ContentColor, FULL, GreyColor } from '../common/constant/global'
import { BookInsert, BookUpdate, BookQueryBooks, BookQuery } from '../common/dao/BookDao'
import { Book } from '../common/model/Book'
import { BookForCategory } from './component/BookForCatgegory'
import router from '@ohos.router'
import { GetBook } from '../common/utils/BookUtils'
import { BookForSearch } from './component/BookForSearch'

@Component
export struct Category {
  @State type: string = "玄幻"

  @Link books: Book[]
  @Link msg: string[]
  @Builder itemEnd(index: number) {
    Column(){
      Image($r('app.media.addShelf'))
        .objectFit(ImageFit.Contain)
        .width("40%")
      Text(this.msg[index]===""?this.books[index].bookIsInShelf?"已在书架":"加入书架":this.msg[index])
        .textAlign(TextAlign.Center)
        .width(FULL)
    }
    .justifyContent(FlexAlign.Center)
    .width("20%")
    .height(FULL)
    .onClick(() => {
      if(this.books[index].bookIsInShelf) {
        this.books[index].bookIsInShelf = false;
        this.msg[index] = "加入书架"
      } else {
        this.books[index].bookIsInShelf = true;
        this.msg[index] = "已在书架"
      }
      BookUpdate(this.books[index])
    })
  }

  query() {
    BookQueryBooks(5, this.type, (ret: Book[])=>{
      this.books = ret
      this.msg = new Array<string>(ret.length).fill("")
    })
  }
  aboutToAppear(){
    BookQueryBooks(5, this.type, async (ret: Book[])=>{
      this.books = ret
      this.msg = new Array<string>(ret.length).fill("")
      const promises = this.books.map((book, i) => {
        return new Promise<void>((resolve, reject) => {
          BookQuery(book, (ret: Book) => {
            this.books[i] = ret;
            GetBook(this.books[i], (ret: Book) => {
              this.books[i] = ret;
              this.msg[i] = this.books[i].bookIsInShelf ? "已在书架" : "加入书架";
              resolve();
            });
          });
        });
      });
      await Promise.all(promises);
    })

  }

  build(){
    Column(){
      // 分类
      Row(){
        List({space: 5}){
          ForEach(TYPES, (item: string, index: number)=>{
            ListItem(){
              Text(item)
                .textAlign(TextAlign.Center)
                .fontColor(this.type===item?BlackColor:GreyColor)
                .width(FULL)
                .height(FULL)
            }
            .width("15%")
            .height(FULL)
            .onClick(()=>{
              this.type=item
              this.query()
            })
          })
        }
        .width(FULL)
        .height(FULL)
        .listDirection(Axis.Horizontal)
      }
      .justifyContent(FlexAlign.SpaceEvenly)
      .borderRadius(20)
      .width(FULL)
      .height("10%")
      .backgroundColor(ContentColor)
      .margin({top: 12})

      // 书籍
      Column(){
        Row(){
          Text(this.type)
            .fontColor(GreyColor)
            .textAlign(TextAlign.Center)
            .width("25%")
            .height(FULL)
        }
        .width(FULL)
        .height("5%")

        Column(){
          List({space: 20}){
            ForEach(this.books, (book: Book, index: number)=>{
              ListItem(){
                BookForSearch({book: book, index: index+1})
              }
              .width(FULL)
              .height("20%")
              .swipeAction({ end: this.itemEnd.bind(this, index) })
              .onClick(()=>{
                BookInsert(book, ()=>{
                  router.pushUrl({
                    url: 'pages/BookCatalog', // 目标url
                    params: book // 添加params属性，传递自定义参数
                  })
                })
              })
            })
          }
          .width(FULL)
          .height(FULL)
          .onReachEnd(()=>{
            BookQueryBooks(20, this.type, (ret: Book[])=>{
              this.books.push(...ret);
              this.msg.push(...new Array<string>(ret.length).fill(""))
            })
          })
        }
        .margin({bottom: 12, left: 12, right: 12})
        .padding(12)
        .width("90%")
        .height("90%")
        .backgroundColor(ContentColor)
        .borderRadius(20)
      }
      .width(FULL)
      .height("90%")
    }
    .height(FULL)
    .width(FULL)
    .backgroundColor(BackgroundColor)
  }
}