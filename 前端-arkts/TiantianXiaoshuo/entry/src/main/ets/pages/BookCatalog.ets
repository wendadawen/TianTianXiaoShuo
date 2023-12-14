
import { Book } from '../common/model/Book'
import router from '@ohos.router';
import { BackgroundColor, BlackColor, BoldColor, CatalogColor, ContentColor, FULL, GreyColor, LineColor, TitleColor } from '../common/constant/global';
import { BookUpdate, BookQueryALlChapter, BookQuery } from '../common/dao/BookDao';
import { GetBook } from '../common/utils/BookUtils';

@Entry
@Component
struct BookCatalog{
  @State book: Book = new Book()
  @State chapters: string[] = []
  @State msg: string = ""
  @State msgRead: string = ""
  @State isLoading: boolean = true
  aboutToAppear(){
    this.book = router.getParams() as Book; // 获取传递过来的参数对象
    GetBook(this.book, (ret: Book)=>{
      this.book = ret
    })
  }
  onPageShow(){
    this.isLoading = true
    BookQuery(this.book, (ret: Book)=>{
      this.book = ret
      GetBook(this.book, (ret: Book)=>{
        this.book = ret
        this.msg = this.book.bookIsInShelf?"已在书架":"加入书架"
        BookQueryALlChapter(this.book, (chapters: string[])=>{
          this.chapters = chapters
          this.msgRead = this.book.bookReadChapter===1?"开始阅读":"继续阅读："+this.chapters[this.book.bookReadChapter-1]
          this.isLoading = false;
        })
      })
    })
  }
  @State isImageLoading: boolean = true
  build(){
    if(this.isLoading) {
      LoadingProgress()
        .color(Color.Gray)
    } else {
      Column(){
        Row(){
          Row(){
            if(this.isImageLoading) {
              LoadingProgress().color(Color.Grey)
                .width(FULL)
                .height(FULL)
            }
            Image(this.book.bookImage)
              .width(FULL)
              .height(FULL)
              .objectFit(ImageFit.Contain)
              .onComplete(()=>{
                this.isImageLoading = false
              })
          }
          .width("40%")
          .height(FULL)
          .margin({left: 24, right: 24})

          Column(){
            Row(){
              Text(this.book.bookName)
                .textOverflow({overflow: TextOverflow.Ellipsis})
                .fontSize(24)
                .fontColor(TitleColor)
                .width(FULL)
                .height(FULL)
                .maxLines(2)
                .textOverflow({overflow: TextOverflow.Ellipsis})
                .padding({right: 36})
            }
            .height("50%")
            .width(FULL)

            Divider().strokeWidth(2).color(LineColor).width(FULL).padding({right: 48})

            Column(){
              Text(this.book.bookAuthor)
                .fontColor(BlackColor)
                .width(FULL)
                .height("30%")

              Text(this.book.bookTags+" | "+this.book.bookStatus)
                .fontColor(GreyColor)
                .width(FULL)
                .height("70%")
            }
            .height("50%")
            .width(FULL)
          }
          .width("55%")
          .height(FULL)
        }
        .width("90%")
        .height("20%")
        .borderRadius(20)
        .margin({top: 12, bottom: 12})
        .backgroundColor(ContentColor)


        Column(){
          Text("      书籍简介")
            .width(FULL)
            .fontSize(20)
            .fontColor("#ff32428d")
            .height("30%")
            .textAlign(TextAlign.Start)

          Divider().strokeWidth(2).color(LineColor).width(FULL).padding({left: 12, right: 12})

          Text(this.book.bookDetail)
            .padding(12)
            .width(FULL)
            .height("70%")
            .textOverflow({overflow: TextOverflow.Ellipsis})
            .maxLines(3)
        }
        .width("90%")
        .height("15%")
        .borderRadius(20)
        .margin({bottom: 12})
        .backgroundColor(ContentColor)


        Column(){
          List({space: 0}){
            ForEach(this.chapters, (chapter: string, index: number)=>{
              ListItem(){
                Column(){
                  Text(chapter)
                    .fontColor(index+1===this.book.bookReadChapter?GreyColor:CatalogColor)
                    .padding({left: 24, right: 24})
                    .maxLines(1)
                    .textOverflow({overflow: TextOverflow.Ellipsis})
                    .width(FULL)
                    .height(FULL)
                    .onClick(()=>{
                      this.book.bookReadChapter = index + 1
                      BookUpdate(this.book)
                      this.msgRead = this.book.bookReadChapter===1?"开始阅读":"继续阅读："+this.chapters[this.book.bookReadChapter-1]
                      router.pushUrl({
                        url: 'pages/BookChapterContent',
                        params: this.book
                      })
                    })
                  Divider().strokeWidth(2).color(LineColor).width(FULL).padding({left: 12, right: 12})
                }
                .width(FULL)
                .height(FULL)
              }
              .width(FULL)
              .height("48vp")
            })
          }
          .width(FULL)
          .height(FULL)
        }
        .width("90%")
        .height("50%")
        .borderRadius(20)
        .margin({bottom: 12})
        .backgroundColor(ContentColor)

        Divider().strokeWidth(2).color(ContentColor).width(FULL)
        Row(){
          Text(this.msg)
            .fontSize(20)
            .textAlign(TextAlign.Center)
            .width("40%")
            .height(FULL)
            .fontColor(ContentColor)
            .backgroundColor("#65bbec")
            .onClick(() => {
              if(this.book.bookIsInShelf) {
                this.book.bookIsInShelf = false;
                this.msg = "加入书架"
              } else {
                this.book.bookIsInShelf = true;
                this.msg = "已在书架"
              }
              BookUpdate(this.book)
            })
          // Divider().strokeWidth(2).color(LineColor).height(FULL).margin({top:24, bottom: 36}).vertical(true)
          Text(this.msgRead)
            .fontSize(20)
            .textAlign(TextAlign.Center)
            .fontColor(ContentColor)
            .backgroundColor("#f77720")
            .maxLines(1)
            .textOverflow({overflow: TextOverflow.Ellipsis})
            .width("40%")
            .height(FULL)
            .onClick(()=>{
              router.pushUrl({
                url: 'pages/BookChapterContent',
                params: this.book
              })
            })
        }
        .width(FULL)
        .justifyContent(FlexAlign.SpaceEvenly)
        .height("10%")
        .backgroundColor(ContentColor)
      }
      .width(FULL)
      .height(FULL)
      .backgroundColor(BackgroundColor)
    }

  }
}