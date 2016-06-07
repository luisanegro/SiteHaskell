{-# LANGUAGE OverloadedStrings, TypeFamilies, QuasiQuotes,
             TemplateHaskell, GADTs, FlexibleInstances,
             MultiParamTypeClasses, DeriveDataTypeable,
             GeneralizedNewtypeDeriving, ViewPatterns, EmptyDataDecls #-}
 
module CadastroLoja where
import Rotas
import Yesod
import Yesod.Core
import Tabelas
import Control.Monad.Logger (runStdoutLoggingT)
import Control.Applicative
import Data.Text

import Database.Persist.Postgresql

mkYesodDispatch "Pagina" pRoutes

formLoja :: Form Loja
formLoja = let
             cnpj = (fieldSettingsLabel MsgCnpj){fsId=Just "hident2",
                           fsTooltip= Nothing,
                           fsName= Nothing,
                           fsAttrs=[("maxlength","18")]}

             cep = (fieldSettingsLabel MsgCep){fsId=Just "hident5",
                           fsTooltip= Nothing,
                           fsName= Nothing,
                           fsAttrs=[("maxlength","9")]}

             cpf = (fieldSettingsLabel MsgCpfDoResponsavel){fsId=Just "hident11",
                           fsTooltip= Nothing,
                           fsName= Nothing,
                           fsAttrs=[("maxlength","14")]}

             rg = (fieldSettingsLabel MsgRgDoResponsavel){fsId=Just "hident12",
                           fsTooltip= Nothing,
                           fsName= Nothing,
                           fsAttrs=[("maxlength","12")]}
           in
           renderDivs $ Loja <$>
           areq textField (fieldSettingsLabel MsgNomeFantasia) Nothing <*>
           areq textField  cnpj Nothing <*>
           areq textField  (fieldSettingsLabel MsgLogradouro) Nothing <*>
           areq textField  (fieldSettingsLabel MsgNumero) Nothing <*>
           areq textField  cep Nothing <*> 
           areq textField  (fieldSettingsLabel MsgBairro) Nothing <*>
           areq textField  (fieldSettingsLabel MsgCidade) Nothing <*>
           areq textField  (fieldSettingsLabel MsgEstado) Nothing <*>
           areq textField  (fieldSettingsLabel MsgTelefone) Nothing <*>
           areq textField  (fieldSettingsLabel MsgEmail) Nothing <*>
           areq textField  (fieldSettingsLabel MsgNomeDoResponsavel) Nothing <*>
           areq textField  cpf Nothing <*>
           areq textField  rg  Nothing


getHomeR :: Handler Html
getHomeR = defaultLayout $ do
                addStylesheet $ StaticR style_css
                $(whamletFile "templates/menu.hamlet")
                $(whamletFile "templates/home.hamlet")


getLojaR :: Handler Html
getLojaR = do
            (widget, enctype) <- generateFormPost formLoja
            defaultLayout $ do
                addStylesheet $ StaticR style_css
                $(whamletFile "templates/menu.hamlet")
                $(whamletFile "templates/cadastrarLoja.hamlet")

postLojaR :: Handler Html
postLojaR = do
           ((result, _), _) <- runFormPost formLoja
           case result of 
               FormSuccess loja -> (runDB $ insert loja) >>= \piid -> redirect (ChecarLojaR piid)
               _ -> redirect ErroR

getLojasR :: Handler Html
getLojasR = do
            lojas <- runDB $ selectList ([]::[Filter Loja]) []
            defaultLayout $ [whamlet|
                <ul>
                    $forall Entity id loja <- lojas
                        <li>[#{fromSqlKey id}] #{lojaNomeFantasia loja}
            |]



getChecarLojaR :: LojaId -> Handler Html
getChecarLojaR pid = do
    loja <- runDB $ get404 pid
    defaultLayout $ do
        addStylesheet $ StaticR style_css
        $(whamletFile "templates/menu.hamlet")
        $(whamletFile "templates/checarLoja.hamlet")

getErroR :: Handler Html
getErroR = defaultLayout [whamlet|
              <p>
               _{MsgErro}
|]



