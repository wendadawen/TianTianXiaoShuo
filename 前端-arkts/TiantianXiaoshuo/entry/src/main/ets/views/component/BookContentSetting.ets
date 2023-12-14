
import { FULL } from '../../common/constant/global'
import { Book } from '../../common/model/Book'
import promptAction from '@ohos.promptAction'
import { BookQueryContent, BookUpdate } from '../../common/dao/BookDao'
import router from '@ohos.router'
import { Color1, Color2, Color3, Color4, Color5, FontC1, FontC2, FontC3, FontC4, FontC5 } from '../../common/constant/ContentColor'

@CustomDialog
export struct BookContentSetting{
  @Link fontSize: number
  @Link bgColor: string
  @Link isUpdown: Boolean
  @Link book: Book
  @Link chapter: string
  @Link content: string
  @Link isLoading: boolean
  @Link fontColor: string

  @Link day_msg: string
  dialogController: CustomDialogController = new CustomDialogController({
    builder: BookContentSetting2({
      fontSize: $fontSize,
      fontColor: $fontColor,
      bgColor: $bgColor,
      isUpdown: $isUpdown,
    }),
    customStyle: true,
    alignment: DialogAlignment.Bottom
  })

  controller: CustomDialogController

  build(){
    Column(){
      Row(){
        Text("上一章")
          .fontColor(this.fontColor)
          .fontSize(this.fontSize)
          .width("50%")
          .height(FULL)
          .textAlign(TextAlign.Center)
          .onClick(()=>{
            if(this.book.bookReadChapter === 1) {
              promptAction.showToast({
                message: "已经在第一章了！",
                duration: 500,
              })
            } else {
              this.book.bookReadChapter -= 1
              this.isLoading = true
              BookUpdate(this.book)
              BookQueryContent(this.book, (chapter: string, content: string)=>{
                this.chapter = chapter
                this.content = content
                this.isLoading = false
                this.controller.close()
              })
            }

          })
        // Divider().strokeWidth(2).backgroundColor(this.fontColor).height(FULL).vertical(true).margin({top:12, bottom: 12})
        Text("下一章")
          .fontColor(this.fontColor)
          .fontSize(this.fontSize)
          .width("50%")
          .height(FULL)
          .textAlign(TextAlign.Center)
          .onClick(()=>{
            if(this.book.bookReadChapter === this.book.bookAllChapterNum) {
              promptAction.showToast({
                message: "已经在最后一章了！",
                duration: 500,
              })
            } else {
              this.book.bookReadChapter += 1
              this.isLoading = true
              BookUpdate(this.book)
              BookQueryContent(this.book, (chapter: string, content: string)=>{
                this.chapter = chapter
                this.content = content
                this.isLoading = false
                this.controller.close()
              })
            }
          })
      }
      .justifyContent(FlexAlign.SpaceEvenly)
      .width(FULL)
      .height("50%")

      Row(){
        Text("目录")
          .fontColor(this.fontColor)
          .fontSize(this.fontSize)
          .width("30%")
          .height(FULL)
          .textAlign(TextAlign.Center)
          .onClick(()=>{
            router.back()
            this.controller.close()
          })
        Text(this.day_msg)
          .fontColor(this.fontColor)
          .fontSize(this.fontSize)
          .width("30%")
          .height(FULL)
          .textAlign(TextAlign.Center)
          .onClick(()=>{
            if(this.day_msg === "夜间") {
              this.day_msg = "白天"
              this.bgColor = Color3
              this.fontColor = FontC3
            } else {
              this.day_msg = "夜间"
              this.bgColor = Color1
              this.fontColor = FontC1
            }
            this.controller.close()
          })
        Text("设置")
          .fontColor(this.fontColor)
          .fontSize(this.fontSize)
          .width("30%")
          .height(FULL)
          .textAlign(TextAlign.Center)
          .onClick(()=>{
            this.dialogController.open()
          })
      }
      .justifyContent(FlexAlign.SpaceEvenly)
      .width(FULL)
      .height("50%")
    }
    .width(FULL)
    .height("20%")
    .backgroundColor(this.bgColor)
  }
}


@CustomDialog
struct BookContentSetting2 {
  controller: CustomDialogController

  @Link fontColor: string
  @Link fontSize: number
  @Link bgColor: string
  @Link isUpdown: Boolean

  build(){
    Column(){
      Row(){
        Text("字号")
          .fontColor(20)
          .fontColor(this.fontColor)
          .textAlign(TextAlign.Center)
          .width("20%")
          .height(FULL)

        Row(){
          Text("A-")
            .textAlign(TextAlign.Center)
            .fontSize(20)
            .fontColor(this.fontColor)
            .width("20%")
            .borderWidth(2).borderColor(this.fontColor).borderRadius(30)
            .onClick(()=>{
              this.fontSize --
              if(this.fontSize === 9) this.fontSize = 10
            })
          Text(this.fontSize+"")
            .fontSize(20)
            .fontColor(this.fontColor)
            .textAlign(TextAlign.Center)
            .width("20%")
            .height(FULL)
          Text("A+")
            .fontSize(20)
            .fontColor(this.fontColor)
            .textAlign(TextAlign.Center)
            .width("20%")
            .borderWidth(2).borderColor(this.fontColor).borderRadius(30)
            .onClick(()=>{
              this.fontSize ++
              if(this.fontSize === 41) this.fontSize = 40
            })
        }
        .justifyContent(FlexAlign.Center)
        .width("80%")
        .height(FULL)

      }
      .width(FULL)
      .height("30%")

      Row(){
        Text("背景")
          .textAlign(TextAlign.Center)
          .fontColor(20)
          .fontColor(this.fontColor)
          .width("20%")
          .height(FULL)

        Row(){
          Button()
            .type(ButtonType.Circle)
            .width("15%")
            .height(FULL)
            .backgroundColor(Color1)
            .borderWidth(2).borderColor(this.bgColor==Color1?Color3:Color.Transparent)
            .onClick(()=>{
              this.bgColor = Color1
              this.fontColor = FontC1
            })

          Button()
            .type(ButtonType.Circle)
            .width("15%")
            .height(FULL)
            .backgroundColor(Color2)
            .borderWidth(2).borderColor(this.bgColor==Color2?Color3:Color.Transparent)
            .onClick(()=>{
              this.bgColor = Color2
              this.fontColor = FontC2
            })

          Button()
            .type(ButtonType.Circle)
            .width("15%")
            .height(FULL)
            .backgroundColor(Color3)
            .borderWidth(2).borderColor(this.bgColor==Color3?Color5:Color.Transparent)
            .onClick(()=>{
              this.bgColor = Color3
              this.fontColor = FontC3
            })

          Button()
            .type(ButtonType.Circle)
            .width("15%")
            .height(FULL)
            .backgroundColor(Color4)
            .borderWidth(2).borderColor(this.bgColor==Color4?Color3:Color.Transparent)
            .onClick(()=>{
              this.bgColor = Color4
              this.fontColor = FontC4
            })

          Button()
            .type(ButtonType.Circle)
            .width("15%")
            .height(FULL)
            .backgroundColor(Color5)
            .borderWidth(2).borderColor(this.bgColor==Color5?Color3:Color.Transparent)
            .onClick(()=>{
              this.bgColor = Color5
              this.fontColor = FontC5
            })
        }
        .justifyContent(FlexAlign.SpaceEvenly)
        .width("80%")
        .height(FULL)
      }
      .width(FULL)
      .height("30%")

    }
    .justifyContent(FlexAlign.SpaceEvenly)
    .width(FULL)
    .height("20%")
    .backgroundColor(this.bgColor)
  }
}
