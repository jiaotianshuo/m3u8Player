# m3u8Player
an iOS video player that can play m3u8 video.
本项目是基于Object-C的AVPlayer实现的一个m3u8格式文件视频播放器。\n
传入一个m3u8视频链接，既可以在线播放，同时也会将视频文件缓存到本地。下次播放相同链接时，会检查本地是否有缓存，若有缓存，播放本地文件。\n
PS：本项目对于缓存的本地文件没有进行分类识别管理。一般只能识别一个视频链接。
