
import { BlackColor, FULL, GreyColor, HighLight } from '../../common/constant/global'
import { Book } from '../../common/model/Book'
import router from '@ohos.router'

@Component
export struct BookForSearch{
  @ObjectLink book: Book
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
          .objectFit(ImageFit.Contain)
          .onComplete(()=>{
            this.isLoading = false
          })
      }
      .width("20%")
      .height(FULL)
      .margin({right: 12})

      Column(){
        Row(){
          Text(this.book.bookName+"/"+this.book.bookAuthor)
            .maxLines(1)
            .textOverflow({overflow: TextOverflow.Ellipsis})
            .fontSize(16)
            .width("67%")
            .height(FULL)
            .fontColor(BlackColor)
          Text("  人气："+this.book.bookRenqi)
            .fontSize(14)
            .fontColor(HighLight)
            .width("33%")
            .height(FULL)
        }
        .justifyContent(FlexAlign.End)
        .width(FULL)
        .height("20%")
        Row(){
          Text(this.book.bookDetail)
            .maxLines(5)
            .fontSize(14)
            .fontColor(GreyColor)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .height("80%")
        .width(FULL)
      }
      .width("75%")
      .height(FULL)
    }
    .width(FULL)
    .height(FULL)
  }

}