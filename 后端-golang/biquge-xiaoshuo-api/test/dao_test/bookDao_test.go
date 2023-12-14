package dao_test

import (
	"biquge-xiaoshuo-api/dao"
	_ "github.com/magiconair/properties/assert"
	"testing"
)

func TestBookquerybooks(t *testing.T) {
	result := dao.BookQueryBooks(5)
	for i := range result {
		print(result[i].BookName + " ")
	}
	println()
}
