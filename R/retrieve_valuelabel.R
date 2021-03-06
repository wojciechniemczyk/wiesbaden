#' Retrieves Value Labels from GENESIS Databases 
#'
#' \code{retrieve_valuelabel} retrieves value labels for variable
#'
#' @param variablename name of the variable 
#' @param valuelabel "*" (default) retrieves all value labels. 
#' @param genesis to authenticate a user and set the database (see below).
#' @param ... other arguments send to the httr::GET request. 
#'   
#' @details  
#'  See the package description (\code{\link{wiebaden}}) for details about setting the login and database. 
#'  
#' @return a \code{data.frame}.
#'
#' @seealso \code{\link{retrieve_datalist}} \code{\link{wiebaden}}
#'
#' @examples 
#'  \dontrun{
#'  # Value labels contain for the variable 'PART04' in the table with the 
#'  # federal election results on the county level. 
#'  # Assumes that user/password are stored in ~/.genesis.json
#'  
#'  metadata <- retrieve_valuelabel(variablename="PART04", genesis=c(db="regio") )
#'  }
#' 
#' 
#' 
#' 
#' @export
retrieve_valuelabel <- function(
	variablename, 
	valuelabel="*", 
	genesis=NULL, ... ) {

	genesis <- make_genesis(genesis)

	baseurl <- paste(set_db(db=genesis['db']), "RechercheService", sep="")

	param <- list(
		method  = 'MerkmalAuspraegungenKatalog',
		kennung  = genesis['user'],
		passwort = genesis['password'],
		namen = variablename,
		auswahl = valuelabel, 
		bereich = 'Alle',
		listenLaenge = '500',
		sprache = 'de')

	datenaufbau <- GET(baseurl, query  = param, ... ) 
	datenaufbau <- content(datenaufbau, type='text/xml', encoding="UTF-8")
	entries <- xml_find_all(datenaufbau, '//merkmalAuspraegungenKatalogEintraege') 

	if ( length(entries)==0  ) return( xml_text(datenaufbau) )
	
	entries <- lapply(entries, function(x) xml_text(xml_find_all(x, './code|./inhalt')) )
	d <- as.data.frame(do.call(rbind, entries))

	if ( ncol(d)==0 ) return("No results found.")
	
	colnames(d) <- c(variablename, "description")

	return(d)
	}

