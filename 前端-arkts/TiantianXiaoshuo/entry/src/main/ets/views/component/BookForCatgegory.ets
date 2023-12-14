
import { FULL } from '../../common/constant/global'
import { Book } from '../../common/model/Book'
import router from '@ohos.router'

@Component
export struct BookForCategory{
  @ObjectLink book: Book
  @State index: number = 0
  build(){
    Row(){
      Text(""+this.index)
        .height(FULL)
        .width("10%")
      Text(this.book.bookName+"/"+this.book.bookAuthor)
        .height(FULL)
        .width("55%")
      Text("人气："+this.book.bookRenqi)
        .height(FULL)
        .width("35%")
    }
    .width(FULL)
    .height(FULL)
  }
}