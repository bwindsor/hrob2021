{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE OverloadedLists #-}
import Data.Function ((&))
import Data.Monoid ((<>))
import qualified GHC.IO.Encoding as E
import Hakyll
import Hakyll.Contrib.Tojnar.Gallery (figureGroups, implicitFigures)
import Hakyll.Contrib.Tojnar.Menu (menuField)
import Hakyll.Contrib.Tojnar.Thumbnail (makeThumbnails)
import Text.Pandoc.Extensions (Extension (..), disableExtension)
import Text.Pandoc.Options (readerExtensions)

config :: Configuration
config = defaultConfiguration {
	deployCommand = "rsync --checksum -av '--groupmap=\\*:krk' public/* tojnar@ogion.cz:/var/www/krk-litvinov.cz/hrob-2020/",
	destinationDirectory = "public",
	previewHost = "0.0.0.0"
}

main :: IO ()
main = do
	E.setLocaleEncoding E.utf8

	hakyllWith config $ do
		match "styles/*" $ do
			route idRoute
			compile compressCssCompiler

		match ("scripts/*" .||. "images/*") $ do
			route idRoute
			compile copyFileCompiler

		match (fromRegex "^pages/(.+/)?@menu\\.md$") $ do
			compile markdownCompiler

		match (fromRegex "^pages/(.+/)?[^@/][^/]+\\.md$") $ do
			route $ stripPages `composeRoutes` setExtension "html"
			let ctx = activeClassField <> langField <> menuField <> defaultContext
			compile $ markdownCompiler
				>>= loadAndApplyTemplate "templates/layout.html" ctx

		match (fromRegex "^pages/" .&&. complement (fromRegex "\\.md$")) $ do
			route $ stripPages `composeRoutes` idRoute
			compile copyFileCompiler

		match "templates/*" $ compile templateCompiler

		version "redirects" $ createRedirects brokenLinks

activeClassField :: Context String
activeClassField = functionField "activeClass" $ \[p] _ -> do
	path <- toFilePath <$> getUnderlying
	return $ if path == p then "active" else ""

langField :: Context String
langField = field "lang" $ \_ -> do
	path <- toFilePath <$> getUnderlying
	return $ takeWhile (/= '/') path

stripPages :: Routes
stripPages = gsubRoute "pages/" (const "")

markdownCompiler :: Compiler (Item String)
markdownCompiler = pandocCompilerWithTransformM readOpts writeOpts filters
	where
		enabledReaderExtensions =
			readerExtensions defaultHakyllReaderOptions
			& disableExtension Ext_markdown_in_html_blocks
			& disableExtension Ext_implicit_figures
		readOpts = defaultHakyllReaderOptions { readerExtensions = enabledReaderExtensions }
		writeOpts = defaultHakyllWriterOptions
		filters = makeThumbnails . implicitFigures . figureGroups


brokenLinks :: [(Identifier, String)]
brokenLinks = [
	-- Root redirects
	("index.html", "/cs/")
	]
