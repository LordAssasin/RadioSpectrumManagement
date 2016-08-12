# =============================================================================
# Import Library
# =============================================================================
library(RCurl)
library(RODBC)
library(dplyr)
library(leaflet)
# =============================================================================
# Download file
# =============================================================================
temp <- tempfile()
download.file("http://www.rsm.govt.nz/online-services-resources/pdf-and-documents-library/tools/spectrum-search-lite/prism.zip",temp)
Prism <- unzip(temp)
# =============================================================================
# Read Prism
# =============================================================================
channel <- odbcConnectAccess("Prism")
associatedlicences <- sqlQuery( channel , paste ("SELECT * FROM associatedlicences"))
clientname <- sqlQuery( channel , paste ("SELECT * FROM clientname"))
emission <- sqlQuery( channel , paste ("SELECT * FROM emission"))
emissionlimit <- sqlQuery( channel , paste ("SELECT * FROM emissionlimit"))
geographicreference <- sqlQuery( channel , paste ("SELECT * FROM geographicreference"))
issuingoffice <- sqlQuery( channel , paste ("SELECT * FROM issuingoffice"))
licence <- sqlQuery( channel , paste ("SELECT * FROM licence"))
licenceconditions <- sqlQuery( channel , paste ("SELECT * FROM licenceconditions"))
licencetype <- sqlQuery( channel , paste ("SELECT * FROM licencetype"))
location <- sqlQuery( channel , paste ("SELECT * FROM location"))
managementright <- sqlQuery( channel , paste ("SELECT * FROM managementright"))
mapdistrict <- sqlQuery( channel , paste ("SELECT * FROM mapdistrict"))
radiationpattern <- sqlQuery( channel , paste ("SELECT * FROM radiationpattern"))
receiveconfiguration <- sqlQuery( channel , paste ("SELECT * FROM receiveconfiguration"))
spectrum <- sqlQuery( channel , paste ("SELECT * FROM spectrum"))
transmitconfiguration <- sqlQuery( channel , paste ("SELECT * FROM transmitconfiguration"))
# =============================================================================
# Create files
# =============================================================================

# =============================================================================
# Spark
# =============================================================================
Spark.Licence <- licence %>% filter(clientid==134563)
Spark.Licence.Spectrum <- licence %>% filter(clientid==134563 & as.integer(licencetypeid %in% c(175,176,177,178)))
Spark.Licence.Fixed    <- licence %>% filter(clientid==134563 & as.integer(licencetypeid %in% c(44,52,73,147)))
Spark.Management.Right <- managementright %>% filter(clientid==134563)
Spark.Licence.Rx <- left_join(Spark.Licence, receiveconfiguration, by = "licenceid")
Spark.Licence.Tx <- left_join(Spark.Licence.Spectrum, transmitconfiguration, by = "licenceid")
Spark.Licence.location <- left_join(Spark.Licence.Tx, location, by = "locationid")
Spark.Licence.Geo <- left_join(Spark.Licence.location, geographicreference, by = "locationid")
Spark.Licence.Geo1 <- Spark.Licence.Geo[Spark.Licence.Geo$georeferencetypeid ==3,]
Spark.Licence.Geo1 <- Spark.Licence.Geo1[!is.na(Spark.Licence.Geo1$easting),]
# =============================================================================
# View Spark Licences on Map using Leaflet package. 
# =============================================================================
Spark.Licence.Geo1 %>% leaflet() %>% addTiles() %>% 
        addMarkers(lng=Spark.Licence.Geo1$easting, lat=Spark.Licence.Geo1$northing, popup= Spark.Licence.Geo1$locationname)
