
import relationalStore from '@ohos.data.relationalStore';



const STORE_CONFIG: relationalStore.StoreConfig = {
  name: 'database.db',
  securityLevel: relationalStore.SecurityLevel.S1
};
export default class Rdb {
  private rdbStore: relationalStore.RdbStore | null = null;
  private tableName: string;
  private sqlCreateTable: string;
  private columns: Array<string>;

  constructor(tableName: string, sqlCreateTable: string, columns: Array<string>) {
    this.tableName = tableName;
    this.sqlCreateTable = sqlCreateTable;
    this.columns = columns;
  }

  getRdbStore(callback: Function=()=>{}) {
    if (!callback || typeof callback === 'undefined' || callback === undefined) {
      return;
    }
    if (this.rdbStore !== null) {
      callback();return
    }
    let context: Context = getContext(this) as Context;
    relationalStore.getRdbStore(context, STORE_CONFIG, (err, rdb) => {
      if (err) {return;}
      this.rdbStore = rdb;
      this.rdbStore.executeSql(this.sqlCreateTable);
      console.log("RDB")
      callback();
    });
  }

  insertData(data: relationalStore.ValuesBucket, callback: Function = () => {
  }) {
    if (!callback || typeof callback === 'undefined' || callback === undefined) {
      return;
    }
    const valueBucket: relationalStore.ValuesBucket = data;
    if (this.rdbStore) {
      console.log(JSON.stringify(valueBucket))
      this.rdbStore.insert(this.tableName, valueBucket, (err, id) => {
        callback(id)
      });
    }
  }

  deleteData(predicates: relationalStore.RdbPredicates, callback: Function = () => {
  }) {
    if (!callback || typeof callback === 'undefined' || callback === undefined) {
      return;
    }
    let resFlag: boolean = false;
    if (this.rdbStore) {
      this.rdbStore.delete(predicates, (err, ret) => {
        if (err) {
          callback(resFlag);
          return;
        }
        callback(!resFlag);
      });
    }
  }

  updateData(predicates: relationalStore.RdbPredicates, data: relationalStore.ValuesBucket, callback: Function = () => {
  }) {
    if (!callback || typeof callback === 'undefined' || callback === undefined) {
      return;
    }
    let resFlag: boolean = false;
    const valueBucket: relationalStore.ValuesBucket = data;
    if (this.rdbStore) {
      this.rdbStore.update(valueBucket, predicates, (err, ret) => {
        if (err) {
          callback(resFlag);
          return;
        }
        callback(!resFlag);
      });
    }
  }

  query(predicates: relationalStore.RdbPredicates, callback: Function = () => {
  }) {
    if (!callback || typeof callback === 'undefined' || callback === undefined) {
      return;
    }
    if (this.rdbStore) {
      this.rdbStore.query(predicates, this.columns, (err, resultSet) => {
        if (err) {
          return;
        }
        callback(resultSet);
        resultSet.close();
      });
    }
  }
}