# !/usr/bin/dev python
# -*- coding:utf-8 -*-

from scrapy.selector import Selector
import re,urllib2
#import chardet,codecs

for rank_num in range(4,10):
    rank_num_url="http://top.chinaz.com/list.aspx?baidu=%d" % rank_num
    req = urllib2.Request(rank_num_url)
    data = urllib2.urlopen(req, timeout=30).read().decode('gb2312')
    #encode=chardet.detect(data)["encoding"]
    hxs = Selector(text=data)
    pagenum=''.join(hxs.xpath('//span[@class="status"]/text()').extract())
    pagenum=int(re.sub('(.*)/',"",pagenum))
    #print type(pagenum)
    for i in range(1,pagenum+1):
        targetUrl = "http://top.chinaz.com/list.aspx?p=%d" % i +"&baidu=%d" % rank_num
        req = urllib2.Request(targetUrl)
        detail_data = urllib2.urlopen(req, timeout=30).read()
        detail_hxs = Selector(text=detail_data)
        rank_url=detail_hxs.xpath('//div[@class="webItemList"]/ul/li/div[@class="info"]/h3/span/text()').extract()
        fname=str(rank_num)+".txt"
        for url in rank_url:
            f=open(fname,'a+')
            f.write(url)
            f.write("\n")