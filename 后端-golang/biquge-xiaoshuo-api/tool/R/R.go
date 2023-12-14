package R

import (
	"crypto/tls"
	"encoding/json"
	"github.com/PuerkitoBio/goquery"
	"golang.org/x/text/encoding/simplifiedchinese"
	"golang.org/x/text/transform"
	"io"
	"io/ioutil"
	"net/http"
	"net/http/cookiejar"
	"net/url"
	"regexp"
	"strings"
	"time"
)

/*=============================================================
http包的精简
=============================================================*/

// 常量
const (
	BaiduUserAgent   = "Mozilla/5.0 (compatible; Baiduspider/2.0;+http://www.baidu.com/search/spider.html）"
	FirefoxUserAgent = "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:34.0) Gecko/20100101 Firefox/34.0"
)

func Get(addr string) string {
	res, err := http.Get(addr)
	if err != nil {
		return ""
	}
	return Read(res)
}

// 读取响应体
func Read(res *http.Response) string {
	all, err := io.ReadAll(res.Body)
	if err != nil {
		//println("[Read error]: ", err.Error())
		return ""
	}
	defer res.Body.Close()
	return string(all)
}

// 读取byte数据
func ReadByte(res *http.Response) []byte {
	all, err := io.ReadAll(res.Body)
	if err != nil {
		return []byte("")
	}
	defer res.Body.Close()
	return all
}

// 读取html
func ReadHtml(res *http.Response) (*goquery.Document, error) {
	/*
		croypto := html.Find("#login-croypto").Text()
		execution := html.Find("#login-page-flowkey").Text()
		type_t := html.Find("#current-login-type").Text()
	*/
	html, err := goquery.NewDocumentFromReader(res.Body)
	defer res.Body.Close()
	if err != nil {
		return nil, err
	}
	return html, nil
}

// 读取json
func ReadJson(res *http.Response) map[string]interface{} {
	ret := make(map[string]interface{})
	all, _ := io.ReadAll(res.Body)
	json.Unmarshal(all, &ret)
	defer res.Body.Close()
	return ret
}

// 读取url的字符串参数
func ReadParam(url *url.URL, param string) string {
	return url.Query().Get(param)
}

// 保存成为文件
func SaveFile(res *http.Response, filePath string) {
	err := ioutil.WriteFile(filePath, ReadByte(res), 0644)
	defer res.Body.Close()
	if err != nil {
		return
	}
}

func SaveFileFromString(s string, filePath string) {
	ioutil.WriteFile(filePath, []byte(s), 0644)
}

func ConvertEncodingToUTF8(str string) string {
	output, _, err := transform.Bytes(simplifiedchinese.GBK.NewDecoder(), []byte(str))
	if err != nil {
		return ""
	}
	return string(output)
}
func FindAll(s string, regex string) [][]string {
	re := regexp.MustCompile(regex)
	matches := re.FindAllStringSubmatch(s, -1)
	return matches
}

func FindSignal(s string, regex string) []string {
	re := regexp.MustCompile(regex)
	return re.FindStringSubmatch(s)
}

// 构造一个客户端
func NewClient() *http.Client {
	jar, _ := cookiejar.New(nil)

	client := &http.Client{
		Timeout: 5 * time.Second,
		Jar:     jar,
		Transport: &http.Transport{
			TLSClientConfig: &tls.Config{InsecureSkipVerify: true},
		},
	}
	// 打开重定向
	client = OpenRedirect(client)
	return client
}

// 客户端取消重定向
func RemoveRedirect(client *http.Client) *http.Client {
	client.CheckRedirect = func(req *http.Request, via []*http.Request) error {
		return http.ErrUseLastResponse
	}
	return client
}

// 客户端打开重定向
func OpenRedirect(client *http.Client) *http.Client {
	client.CheckRedirect = func(req *http.Request, via []*http.Request) error {
		if len(via) > 10 {
			//println("    重定向次数过多!")
			return http.ErrUseLastResponse
		}
		//println("	重定向: " + req.URL.String())
		return nil
	}
	return client
}

// 手动重定向
func ManualRedirect(client *http.Client, req *http.Request) (*http.Response, error) {
	// 取消重定向
	client = RemoveRedirect(client)
	// 发送初始请求
	res, err := SendRequest(client, req)
	if err != nil {
		return nil, err
	}
	// 获取重定向地址
	Url := res.Header.Get("Location")
	for Url != "" {
		println("	重定向: " + res.Header.Get("Location"))
		// 构造重定向请求  (在客户端跳转url，redirect都是get的方式请求, 不特别说明的话)
		request, err := NewRequest(http.MethodGet, Url, "")
		if err != nil {
			return nil, err
		}
		//发送重定向请求
		res, err = SendRequest(client, request)
		if err != nil {
			return nil, err
		}
		// 获取下一次重定向请求地址
		Url = res.Header.Get("Location")
	}
	// 重新打开重定向
	client = OpenRedirect(client)
	return res, nil
}

// 构造一个请求
func NewRequest(method, url string, body string) (*http.Request, error) {
	req, err := http.NewRequest(method, url, strings.NewReader(body))
	if body == "" {
		req, err = http.NewRequest(method, url, nil)
	}
	if err != nil {
		return nil, err
	}
	req.Header.Add("User-Agent", FirefoxUserAgent)
	if method == http.MethodPost {
		// 默认表达提交
		req.Header.Add("Content-Type", "application/x-www-form-urlencoded")
		// 告诉服务器这是一个Ajax请求
		req.Header.Add("X-Requested-With", "XMLHttpRequest")
	}
	return req, err
}

// 发送请求
func SendRequest(client *http.Client, req *http.Request) (*http.Response, error) {
	res, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	return res, err
}

// 获取cookie
func FindCookie(client *http.Client, jarUrl string, cookieName string) (cookieVal string) {
	jarUrlT, _ := url.Parse(jarUrl)
	cookies := client.Jar.Cookies(jarUrlT)
	for _, cookie := range cookies {
		if cookie.Name == cookieName {
			cookieVal = cookie.Value
			return cookieVal
		}
	}
	return ""
}

// 读取所有cookies
func ReadCookies(client *http.Client, jarUrl string) {
	println("---------------------")
	jarUrlT, _ := url.Parse(jarUrl)
	cookies := client.Jar.Cookies(jarUrlT)
	for _, cookie := range cookies {
		println(cookie.Name, cookie.Value)
	}
	println("---------------------")
}

// 设置cookies
func SetCookies(client *http.Client, jarUrl string, cookies map[string]string) *http.Client {

	var cookiesT []*http.Cookie
	for name, val := range cookies {
		cookiesT = append(cookiesT, &http.Cookie{
			Name:  name,
			Value: url.QueryEscape(val),
		})
	}

	jarUrlT, _ := url.Parse(jarUrl)
	client.Jar.SetCookies(jarUrlT, cookiesT)

	return client
}

// url编码
func UrlParse(addr string) string {
	urlEncode := url.QueryEscape(addr)
	return urlEncode
}
