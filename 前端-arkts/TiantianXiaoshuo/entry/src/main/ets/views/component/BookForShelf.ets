
import { BlackColor, FULL, GreyColor } from '../../common/constant/global'
import { Book } from '../../common/model/Book'
import router from '@ohos.router'

@Component
export struct BookForShelf{
  @State book: Book = new Book()
  @State index: number = 0
  @State isLoading: boolean = true
  build(){
    Row(){
      Column(){
        if(this.isLoading) {
          LoadingProgress().color(Color.Blue)
            .width(FULL)
            .height(FULL)
        }
        Image(this.book.bookImage)
          .width(FULL)
          .height(FULL)
          .objectFit(ImageFit.Contain)
          .onComplete(()=>{
            this.isLoading = false
          })
      }
      .width("30%")
      .height(FULL)
      .margin({right: 12})

      Column(){
        Text(this.book.bookName+"/"+this.book.bookAuthor)
          .maxLines(1)
          .textOverflow({overflow: TextOverflow.Ellipsis})
          .fontSize(16)
          .width(FULL)
          .height("50%")
          .fontColor(BlackColor)

        Text("第"+this.book.bookReadChapter+"章/共"+this.book.bookAllChapterNum+"章")
          .width(FULL)
          .height("50%")
          .fontSize(14)
          .fontColor(GreyColor)
      }
      .width("70%")
      .height(FULL)
    }
    .width(FULL)
    .height(FULL)

  }
}