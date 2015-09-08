library(httr)
library(XML)
library(stringr)
library(dplyr)


# log in account setting ----------------------------------------------------

email= ""
password= ""

# log in --------------------------------------------------------------------

## get token
res_test <- GET("https://www.coursera.org/login")

headers <- add_headers(`User-Agent`="Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.85 Safari/537.36",
                       `Accept`="text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
                       `Accept-Language`="zh-TW,zh;q=0.8,en;q=0.6,zh-CN;q=0.4,ja;q=0.2",
                       Referer="https://www.coursera.org/login",
                       `X-CSRF2-Cookie` = sprintf("csrf2_token_%s", 
                                                  stringi::stri_rand_strings(n=1, length=8, pattern="[A-Za-z0-9]")),
                       `X-CSRF2-Token`=stringi::stri_rand_strings(n=1, length=24, pattern="[A-Za-z0-9]"),
                       `X-CSRFToken`=stringi::stri_rand_strings(n=1, length=8, pattern="[A-Za-z0-9]"),
                       `X-Requested-With`="XMLHttpRequest"
                       )
# cookies(res_test)
cookies <- as.list(setNames(cookies(res_test)$value, cookies(res_test)$name))
cookies <- c(cookies, 
             `__204r`="",
             `ip_origin`="TW",
             `ip_currency`="USD",
             `_gat_UA-63982927-1`="1",
             `_ga`="GA1.2.773044410.1441731507",
             `_gat_UA-28377374-1`="1",
             `csrftoken` = unname(headers$headers["X-CSRFToken"]),
             setNames(headers$headers["X-CSRF2-Token"], 
                      headers$headers["X-CSRF2-Cookie"])
             )

## log in
v3 <- httr::POST("https://www.coursera.org/api/login/v3",
           headers,
           do.call(set_cookies, cookies),
           body = list(code= "",
                       email= email,
                       password= password,
                       webrequest= "true"),
           encode = "json"
)

cookies(v3)

# parse -------------------------------------------------------------------

class_name <- "repdata-032"
class_url <- sprintf("https://class.coursera.org/%s/lecture", class_name)


## fetch response
headers_2 <- add_headers(`User-Agent`="Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.85 Safari/537.36",
                         `Accept`="text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
                         `Accept-Language`="zh-TW,zh;q=0.8,en;q=0.6,zh-CN;q=0.4,ja;q=0.2",
                         Host="class.coursera.org"
                         )

cookies_2 <- c(as.list(setNames(cookies(v3)$value, cookies(v3)$name)),
               `_ga`="GA1.2.773044410.1441731507",
               `__204r`=""
               )

response <- httr::GET(class_url,
                      headers_2,
                      do.call(set_cookies, cookies_2)
)

node <- content(response, encoding = "UTF-8")

## get video url
video_nodeset <- node["//div[@class='course-lecture-item-resource']/a"]
video_url <- xmlSApply(video_nodeset, xmlAttrs)["href",]
