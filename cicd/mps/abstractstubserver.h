/**
 * This file is generated by jsonrpcstub, DO NOT CHANGE IT MANUALLY!
 */

#ifndef JSONRPC_CPP_STUB_ABSTRACTSTUBSERVER_H_
#define JSONRPC_CPP_STUB_ABSTRACTSTUBSERVER_H_

#include <jsonrpccpp/server.h>

class AbstractStubServer : public jsonrpc::AbstractServer<AbstractStubServer>
{
    public:
        AbstractStubServer(jsonrpc::AbstractServerConnector &conn, jsonrpc::serverVersion_t type = jsonrpc::JSONRPC_SERVER_V2) : jsonrpc::AbstractServer<AbstractStubServer>(conn, type)
        {
            this->bindAndAddMethod(jsonrpc::Procedure("list", jsonrpc::PARAMS_BY_NAME, jsonrpc::JSON_OBJECT,  NULL), &AbstractStubServer::listI);
            this->bindAndAddMethod(jsonrpc::Procedure("info", jsonrpc::PARAMS_BY_NAME, jsonrpc::JSON_OBJECT,  NULL), &AbstractStubServer::infoI);
            this->bindAndAddMethod(jsonrpc::Procedure("rand", jsonrpc::PARAMS_BY_NAME, jsonrpc::JSON_OBJECT,  NULL), &AbstractStubServer::randI);
            this->bindAndAddMethod(jsonrpc::Procedure("ok", jsonrpc::PARAMS_BY_NAME, jsonrpc::JSON_OBJECT,  NULL), &AbstractStubServer::okI);
            this->bindAndAddMethod(jsonrpc::Procedure("play", jsonrpc::PARAMS_BY_NAME, jsonrpc::JSON_OBJECT,  NULL), &AbstractStubServer::playI);
            this->bindAndAddMethod(jsonrpc::Procedure("pause", jsonrpc::PARAMS_BY_NAME, jsonrpc::JSON_OBJECT,  NULL), &AbstractStubServer::pauseI);
            this->bindAndAddMethod(jsonrpc::Procedure("stop", jsonrpc::PARAMS_BY_NAME, jsonrpc::JSON_OBJECT,  NULL), &AbstractStubServer::stopI);
            this->bindAndAddMethod(jsonrpc::Procedure("prev", jsonrpc::PARAMS_BY_NAME, jsonrpc::JSON_OBJECT,  NULL), &AbstractStubServer::prevI);
            this->bindAndAddMethod(jsonrpc::Procedure("next", jsonrpc::PARAMS_BY_NAME, jsonrpc::JSON_OBJECT,  NULL), &AbstractStubServer::nextI);
            this->bindAndAddMethod(jsonrpc::Procedure("artist", jsonrpc::PARAMS_BY_NAME, jsonrpc::JSON_OBJECT,  NULL), &AbstractStubServer::artistI);
            this->bindAndAddMethod(jsonrpc::Procedure("album", jsonrpc::PARAMS_BY_NAME, jsonrpc::JSON_OBJECT, "artist",jsonrpc::JSON_STRING,"pos",jsonrpc::JSON_INTEGER, NULL), &AbstractStubServer::albumI);
            this->bindAndAddMethod(jsonrpc::Procedure("pos", jsonrpc::PARAMS_BY_NAME, jsonrpc::JSON_OBJECT, "pos",jsonrpc::JSON_INTEGER, NULL), &AbstractStubServer::posI);
            this->bindAndAddMethod(jsonrpc::Procedure("dir", jsonrpc::PARAMS_BY_NAME, jsonrpc::JSON_OBJECT, "path",jsonrpc::JSON_STRING, NULL), &AbstractStubServer::dirI);
            this->bindAndAddNotification(jsonrpc::Procedure("quit", jsonrpc::PARAMS_BY_NAME,  NULL), &AbstractStubServer::quitI);
            this->bindAndAddMethod(jsonrpc::Procedure("musicDirectory", jsonrpc::PARAMS_BY_NAME, jsonrpc::JSON_STRING,  NULL), &AbstractStubServer::musicDirectoryI);
            this->bindAndAddMethod(jsonrpc::Procedure("checksum", jsonrpc::PARAMS_BY_NAME, jsonrpc::JSON_OBJECT,  NULL), &AbstractStubServer::checksumI);
        }

        inline virtual void listI(const Json::Value &/*request*/, Json::Value &response)
        {
            response = this->list();
        }
        inline virtual void infoI(const Json::Value &/*request*/, Json::Value &response)
        {
            response = this->info();
        }
        inline virtual void randI(const Json::Value &/*request*/, Json::Value &response)
        {
            response = this->rand();
        }
        inline virtual void okI(const Json::Value &/*request*/, Json::Value &response)
        {
            response = this->ok();
        }
        inline virtual void playI(const Json::Value &/*request*/, Json::Value &response)
        {
            response = this->play();
        }
        inline virtual void pauseI(const Json::Value &/*request*/, Json::Value &response)
        {
            response = this->pause();
        }
        inline virtual void stopI(const Json::Value &/*request*/, Json::Value &response)
        {
            response = this->stop();
        }
        inline virtual void prevI(const Json::Value &/*request*/, Json::Value &response)
        {
            response = this->prev();
        }
        inline virtual void nextI(const Json::Value &/*request*/, Json::Value &response)
        {
            response = this->next();
        }
        inline virtual void artistI(const Json::Value &/*request*/, Json::Value &response)
        {
            response = this->artist();
        }
        inline virtual void albumI(const Json::Value &request, Json::Value &response)
        {
            response = this->album(request["artist"].asString(), request["pos"].asInt());
        }
        inline virtual void posI(const Json::Value &request, Json::Value &response)
        {
            response = this->pos(request["pos"].asInt());
        }
        inline virtual void dirI(const Json::Value &request, Json::Value &response)
        {
            response = this->dir(request["path"].asString());
        }
        inline virtual void quitI(const Json::Value &/*request*/)
        {
            this->quit();
        }
        inline virtual void musicDirectoryI(const Json::Value &/*request*/, Json::Value &response)
        {
            response = this->musicDirectory();
        }
        inline virtual void checksumI(const Json::Value &/*request*/, Json::Value &response)
        {
            response = this->checksum();
        }
        virtual Json::Value list() = 0;
        virtual Json::Value info() = 0;
        virtual Json::Value rand() = 0;
        virtual Json::Value ok() = 0;
        virtual Json::Value play() = 0;
        virtual Json::Value pause() = 0;
        virtual Json::Value stop() = 0;
        virtual Json::Value prev() = 0;
        virtual Json::Value next() = 0;
        virtual Json::Value artist() = 0;
        virtual Json::Value album(const std::string& artist, int pos) = 0;
        virtual Json::Value pos(int pos) = 0;
        virtual Json::Value dir(const std::string& path) = 0;
        virtual void quit() = 0;
        virtual std::string musicDirectory() = 0;
        virtual Json::Value checksum() = 0;
};

#endif //JSONRPC_CPP_STUB_ABSTRACTSTUBSERVER_H_
