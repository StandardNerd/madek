/**
 * Attribution-Non-Commercial-Share Alike 2.0 UK: England & Wales
 *
 * author Christopher Blum
 *    - based on the idea of Remy Sharp, http://remysharp.com/2009/01/26/element-in-view-event-plugin/
 *    - forked from http://github.com/zuk/jquery.inview/
 */
(function(d){function n(){var a,f={height:window.innerHeight,width:window.innerWidth};if(!f.height)if((a=document.compatMode)||!d.support.boxModel){a=a==="CSS1Compat"?document.documentElement:document.body;f={height:a.clientHeight,width:a.clientWidth}}return f}setInterval(function(){var a=[],f,k=0,i,c,o=d.expando;d.each(d.cache,function(q,j){var g=j.events;if(!g)g=(j=this[o])&&j.events;if(g&&g.inview)if(g.live){var p=d(j.handle.elem);d.each(g.live,function(){if(this.origType.substr(0,6)==="inview")a=
a.concat(p.find(this.selector).toArray())})}else a.push(j.handle.elem)});if(f=a.length){i=n();for(c={top:window.pageYOffset||document.documentElement.scrollTop||document.body.scrollTop,left:window.pageXOffset||document.documentElement.scrollLeft||document.body.scrollLeft};k<f;k++)if(d.contains(document.documentElement,a[k])){var h=d(a[k]),e={height:h.height(),width:h.width()},b=h.offset(),l=h.data("inview"),m;if(b.top+e.height>c.top&&b.top<c.top+i.height&&b.left+e.width>c.left&&b.left<c.left+i.width){m=
c.left>b.left?"right":c.left+i.width<b.left+e.width?"left":"both";e=c.top>b.top?"bottom":c.top+i.height<b.top+e.height?"top":"both";b=m+"-"+e;if(!l||l!==b)h.data("inview",b).trigger("inview",[true,m,e])}else l&&h.data("inview",false).trigger("inview",[false])}}},250)})(jQuery);