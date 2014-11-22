import urllib2
import urllib
import os

currentdevice = os.environ["currentdevice"]

class LatestRomUtil:

  def __init__(self, device):
    self.changeDevice(device)

  def __getPage(self, url, retRedirUrl = False):
    try:
      bOpener = urllib2.build_opener()
      bOpener.addheaders = [("User-agent", "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/33.0.1750.146 Safari/537.36")]
      pResponse = bOpener.open(url)
      if retRedirUrl == True:
        return pResponse.geturl()
      else:
        pageData = pResponse.read()
        return pageData
    except Exception:
      return ""

  def changeDevice(self, device):
    self.device = device.strip().lower()

  def dlSuperSU(self):
    if currentdevice == "sojus":
      getUrl = self.__getPage("http://download.chainfire.eu/supersu", True)
    elif currentdevice == "sojuk":
      getUrl = self.__getPage("http://download.chainfire.eu/supersu", True)
    elif currentdevice == "sojua":
      getUrl = self.__getPage("http://download.chainfire.eu/supersu", True)
    elif currentdevice == "soju":
      getUrl = self.__getPage("http://download.chainfire.eu/supersu", True)
    elif currentdevice == "mysidspr":
      getUrl = self.__getPage("http://download.chainfire.eu/293/CF-Root/CF-Auto-Root/CF-Auto-Root-toroplus-mysidspr-galaxynexus.zip", True)
    elif currentdevice == "mysid":
      getUrl = self.__getPage("http://download.chainfire.eu/292/CF-Root/CF-Auto-Root/CF-Auto-Root-toro-mysid-galaxynexus.zip", True)
    elif currentdevice == "yakju":
      getUrl = self.__getPage("http://download.chainfire.eu/296/CF-Root/CF-Auto-Root/CF-Auto-Root-maguro-yakju-galaxynexus.zip", True)
    elif currentdevice == "takju":
      getUrl = self.__getPage("http://download.chainfire.eu/291/CF-Root/CF-Auto-Root/CF-Auto-Root-maguro-takju-galaxynexus.zip", True)
    elif currentdevice == "occam":
      getUrl = self.__getPage("http://download.chainfire.eu/297/CF-Root/CF-Auto-Root/CF-Auto-Root-mako-occam-nexus4.zip", True)
    elif currentdevice == "shamu":
      getUrl = self.__getPage("http://download.chainfire.eu/628/CF-Root/CF-Auto-Root/CF-Auto-Root-shamu-shamu-nexus6.zip", True)
    elif currentdevice == "hammerhead":
      getUrl = self.__getPage("http://download.chainfire.eu/363/CF-Root/CF-Auto-Root/CF-Auto-Root-hammerhead-hammerhead-nexus5.zip", True)
    elif currentdevice == "nakasi":
      getUrl = self.__getPage("http://download.chainfire.eu/295/CF-Root/CF-Auto-Root/CF-Auto-Root-grouper-nakasi-nexus7.zip", True)
    elif currentdevice == "nakasig":
      getUrl = self.__getPage("http://download.chainfire.eu/294/CF-Root/CF-Auto-Root/CF-Auto-Root-tilapia-nakasig-nexus7.zip", True)
    elif currentdevice == "razor":
      getUrl = self.__getPage("http://download.chainfire.eu/347/CF-Root/CF-Auto-Root/CF-Auto-Root-flo-razor-nexus7.zip", True)
    elif currentdevice == "razorg":
      getUrl = self.__getPage("http://download.chainfire.eu/361/CF-Root/CF-Auto-Root/CF-Auto-Root-deb-razorg-nexus7.zip", True)
    elif currentdevice == "mantaray":
      getUrl = self.__getPage("http://download.chainfire.eu/290/CF-Root/CF-Auto-Root/CF-Auto-Root-manta-mantaray-nexus10.zip", True)
    elif currentdevice == "volantis":
      getUrl = self.__getPage("http://download.chainfire.eu/595/CF-Root/CF-Auto-Root/CF-Auto-Root-flounder-volantis-nexus9.zip", True)
  elif currentdevice == "supersu":
      getUrl = self.__getPage("http://download.chainfire.eu/supersu", True)
    else:
      exit()
    latestUrl = getUrl + "?retrieve_file=1"
    return latestUrl


# below is example usage
romUtil = LatestRomUtil("tf300t")

urllib.urlretrieve (romUtil.dlSuperSU(), "root.zip")
