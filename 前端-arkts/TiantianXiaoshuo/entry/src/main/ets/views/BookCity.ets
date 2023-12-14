
import { BackgroundColor, ContentColor, FULL, GreyColor } from '../common/constant/global'
import { BookInsert, BookUpdate, BookQueryBooks, BookQuery, BookSearch } from '../common/dao/BookDao'
import { Book } from '../common/model/Book'
import { BookForSearch } from './component/BookForSearch'
import router from '@ohos.router'
import { GetBook } from '../common/utils/BookUtils'
import call from '@ohos.telephony.call'

@Component
export struct BookCity {
  @Link books: Book[]
  private isSearch: boolean = false

  aboutToAppear(){
    BookQueryBooks(5, "全部", async (ret: Book[])=>{
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

  private Key: string =""
  search(){
    if(this.isSearch == false) {
      BookSearch(5, 0, this.Key, async (ret: Book[])=>{
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
        this.isSearch = true
      })
    } else {
      BookSearch(10, this.books.length, this.Key, async (ret: Book[])=>{
        this.books.push(...ret)
        this.msg.push(...new Array<string>(ret.length).fill(""))
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
        this.isSearch = true
      })
    }
  }

  build(){
    Column(){
      Column(){
        Search({ placeholder: "搜索内容..." })
          .width(FULL)
          .backgroundColor(ContentColor)
          .searchButton('搜索')
          .onChange((val: string)=>{
            if(val === "" && this.isSearch==true) {
              this.aboutToAppear()
              this.isSearch = false
            }
          })
          .onSubmit((key: string)=>{
            this.Key = key
            this.search()
          })
      }
      .width(FULL)
      .height("10%")
      .padding(12)


      Column(){
        // 排名依据
        Row(){
          Text("综合")
            .fontColor(GreyColor)
            .textAlign(TextAlign.Center)
            .width("25%")
            .height(FULL)
        }
        .width(FULL)
        .height("5%")


        // 书籍信息
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
            if(this.isSearch == false) {
              BookQueryBooks(10, "全部", (ret: Book[])=>{
                this.books.push(...ret);
                this.msg.push(...new Array<string>(ret.length).fill(""))
              })
            } else {
              this.search()
            }
          })
        }
        .margin(12)
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
