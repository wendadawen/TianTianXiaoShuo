
import relationalStore from '@ohos.data.relationalStore';
import { Book } from '../model/Book';
import Rdb from './Rdb';


const tableName:string =  'bookTable'
const sqlCreate:string = `
CREATE TABLE bookTable (
    bookName VARCHAR(255) PRIMARY KEY,
    bookAuthor VARCHAR(255),
    bookDetail TEXT ,
    bookUpdateTime DATETIME,
    bookStatus VARCHAR(50),
    bookImage VARCHAR(255),
    bookRenqi VARCHAR(255),
    bookTags VARCHAR(255),
    bookLatestChapter VARCHAR(255),
    bookReadChapter INT,
    bookIsInShelf BOOLEAN,
    bookAllChapterNum INT,
    bookPage VARCHAR(255)
)
`
const columns:Array<string> = ['bookName', 'bookAuthor', 'bookDetail', 'bookUpdateTime', 'bookStatus', 'bookImage', 'bookRenqi', 'bookTags',
'bookLatestChapter', 'bookReadChapter', 'bookIsInShelf', 'bookAllChapterNum', 'bookPage']
export default class BookTable {
  private bookTable = new Rdb(tableName, sqlCreate,columns);

  constructor(callback: Function=()=>{}) {
    this.bookTable.getRdbStore(callback);
  }

  getRdbStore(callback: Function=()=>{}) {
    this.bookTable.getRdbStore(callback);
  }

  insertData(book: Book, callback: Function) {
    const valueBucket: relationalStore.ValuesBucket = generateBucket(book);
    this.bookTable.insertData(valueBucket, callback);
  }

  deleteData(book: Book, callback: Function) {
    let predicates = new relationalStore.RdbPredicates(tableName);
    predicates.equalTo('bookName', book.bookName);
    this.bookTable.deleteData(predicates, callback);
  }

  updateData(book: Book, callback: Function) {
    const valueBucket: relationalStore.ValuesBucket = generateBucket(book);
    let predicates = new relationalStore.RdbPredicates(tableName);
    predicates.equalTo('bookName', book.bookName,);
    this.bookTable.updateData(predicates, valueBucket, callback);
  }

  query(predicates: relationalStore.RdbPredicates, callback: Function) {
    this.bookTable.query(predicates, (resultSet: relationalStore.ResultSet) => {
      let count: number = resultSet.rowCount;
      if (count === 0 || typeof count === 'string') {callback([]);}
      else {
        resultSet.goToFirstRow();
        const result: Book[] = [];
        for (let i = 0; i < count; i++) {
          let tmp: Book = new Book();
          tmp.bookName = resultSet.getString(resultSet.getColumnIndex('bookName'));
          tmp.bookAuthor = resultSet.getString(resultSet.getColumnIndex('bookAuthor'))
          tmp.bookDetail = resultSet.getString(resultSet.getColumnIndex('bookDetail'))
          tmp.bookUpdateTime = new Date(resultSet.getString(resultSet.getColumnIndex('BookUpdateTime')))
          tmp.bookStatus = resultSet.getString(resultSet.getColumnIndex('bookStatus'))
          tmp.bookImage = resultSet.getString(resultSet.getColumnIndex('bookImage'))
          tmp.bookRenqi = resultSet.getString(resultSet.getColumnIndex('bookRenqi'))
          tmp.bookTags = resultSet.getString(resultSet.getColumnIndex('bookTags'))
          tmp.bookLatestChapter = resultSet.getString(resultSet.getColumnIndex('bookLatestChapter'))
          tmp.bookReadChapter = resultSet.getDouble(resultSet.getColumnIndex('BookReadChapter'))
          tmp.bookIsInShelf = resultSet.getString(resultSet.getColumnIndex('bookIsInShelf'))!='0'
          tmp.bookAllChapterNum = resultSet.getDouble(resultSet.getColumnIndex('bookAllChapterNum'))
          tmp.bookPage = resultSet.getString(resultSet.getColumnIndex('bookPage'))
          result[i] = tmp;
          resultSet.goToNextRow();
        }
        callback(result);
      }
    });
  }
  // 查询所有
  queryAll(callback: Function) {
    let predicates = new relationalStore.RdbPredicates(tableName);
    this.query(predicates, callback)
  }
  // 查询单个
  querySignal(book: Book, callback?: Function) {
    let predicates = new relationalStore.RdbPredicates(tableName)
    predicates.equalTo('bookName', book.bookName)
    this.query(predicates, callback)
  }
  // 查询书架上的
  queryShelf(callback?: Function) {
    let predicates = new relationalStore.RdbPredicates(tableName)
    predicates.equalTo('bookIsInShelf', true)
    this.query(predicates, callback)
  }
  // 查询不在书架上的
  queryHistory(callback?: Function) {
    let predicates = new relationalStore.RdbPredicates(tableName)
    predicates.equalTo('bookIsInShelf', false)
    this.query(predicates, callback)
  }
}

function generateBucket(book: Book): relationalStore.ValuesBucket {
  let tmp: relationalStore.ValuesBucket = {};
  tmp.bookName = book.bookName
  tmp.bookAuthor = book.bookAuthor
  tmp.bookDetail = book.bookDetail
  tmp.bookUpdateTime = book.bookUpdateTime.toISOString()
  tmp.bookStatus = book.bookStatus
  tmp.bookImage = book.bookImage
  tmp.bookRenqi = book.bookRenqi
  tmp.bookTags = book.bookTags
  tmp.bookLatestChapter = book.bookLatestChapter
  tmp.bookReadChapter = book.bookReadChapter
  tmp.bookIsInShelf = book.bookIsInShelf
  tmp.bookAllChapterNum = book.bookAllChapterNum
  tmp.bookPage = book.bookPage
  return tmp;
}
