
import { FULL } from '../common/constant/global'
import { BookContentSetting } from '../views/component/BookContentSetting'
import router from '@ohos.router'
import { Book } from '../common/model/Book'
import { BookQueryContent } from '../common/dao/BookDao'
import { GetBook } from '../common/utils/BookUtils'
import { Color1, FontC1 } from '../common/constant/ContentColor'
@Entry
@Component
struct BookChapterContent{
  @State chapter: string = ""
  @State content:string = ""
  @State book: Book = new Book()
  @State fontSize: number = 22
  @State bgColor: string = Color1
  @State fontColor: string = FontC1
  @State isUpdown: boolean = true
  @State isLoading: boolean = true
  @State day_msg: string = "夜间"
  scroller: Scroller = new Scroller()
  dialogController: CustomDialogController = new CustomDialogController({
    builder: BookContentSetting({
      fontSize: $fontSize,
      fontColor: $fontColor,
      bgColor: $bgColor,
      isUpdown: $isUpdown,
      book: $book,
      chapter: $chapter,
      content: $content,
      isLoading: $isLoading,
      day_msg: $day_msg
    }),
    customStyle: true,
    alignment: DialogAlignment.Bottom
  });
  aboutToAppear(){
    this.book = router.getParams() as Book
    GetBook(this.book, (ret: Book)=>{
      this.book = ret
    })
  }
  onPageShow(){
    BookQueryContent(this.book, (chapter: string, content: string)=>{
      this.chapter = chapter
      this.content = content
      this.isLoading = false
    })
  }

  build(){
    if(this.isLoading) {
      LoadingProgress()
        .color(Color.Gray)
    } else {
      Column(){
        Scroll(this.scroller) {
          Column(){
            Column(){
              Text(this.chapter)
                .padding({left: 24, right: 24})
                .width(FULL)
                .fontSize(25+(this.fontSize-16))
                .fontColor(this.fontColor)
                .textAlign(TextAlign.Center)
            }
            .justifyContent(FlexAlign.End)
            .width(FULL)
            .height("15%")

            Text(this.content)
              .padding({left: 24, right: 24})
              .fontColor(this.fontColor)
              .fontSize(this.fontSize)
              .width(FULL)
              .lineHeight(40+this.fontSize)
          }
          .width(FULL)
        }
        .width(FULL)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width(FULL)
      .height(FULL)
      .backgroundColor(this.bgColor)
      .onClick(()=>{
        this.dialogController.open()
      })
    }
  }
}