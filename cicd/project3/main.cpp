/******************************************************************************!
 * \file main.cpp
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#include <SimpleAmqpClient/SimpleAmqpClient.h>
#include <SimpleAmqpClient/AmqpLibraryException.h>
#include <iostream>

/******************************************************************************!
 * \fn loop
 ******************************************************************************/
bool
loop(AmqpClient::Channel::ptr_t channel, std::string_view tag)
{
    bool quit = false;
    auto envelope = channel->BasicConsumeMessage(static_cast<std::string>(tag));
    std::string str(envelope->Message()->Body());
    std::cout << str << std::endl;

    auto message = AmqpClient::BasicMessage::Create();
    /*  */ if (str == "status") {
        message->Body("status: ok");
    } else if (str == "quit") {
        message->Body("quit: ok");
        quit = true;
    }
    message->CorrelationId(envelope->Message()->CorrelationId());
    channel->BasicPublish("",
                          envelope->Message()->ReplyTo(),
                          message,
                          true,  // mandatory
                          false);  // immediate
    return ! quit;
}

/******************************************************************************!
 * \fn main
 ******************************************************************************/
int
main(int, char**)
{
    std::string queue(std::string("project-three"));
    AmqpClient::Channel::ptr_t channel = nullptr;
    bool quit = false;

    while (! quit) {
        std::string tag;

        try {
            if (channel == nullptr) {
                channel = AmqpClient::Channel::Create();
            }
            channel->DeclareQueue(queue,
                                  false,  // passive
                                  false,  // durable
                                  false,  // exclusive
                                  true);  // auto_delete
            tag = channel->BasicConsume(queue,
                                        "",  // consumer_tag
                                        0,  // no_local
                                        1,  // no_ack
                                        0);  // exclusive
        } catch (AmqpClient::ConnectionClosedException& e) {
            std::cerr << e.what() << std::endl;
            sleep(5);
            channel = nullptr;
            continue;
        } catch (AmqpClient::ConnectionForcedException& e) {
            std::cerr << e.what() << std::endl;
            sleep(5);
            channel = nullptr;
            continue;
        } catch (AmqpClient::AmqpLibraryException& e) {
            std::cerr << e.what() << std::endl;
            sleep(5);
            continue;
        }

        while (! quit) {
            try {
                if (! loop(channel, tag)) {
                    quit = true;
                }
            } catch (AmqpClient::ConnectionClosedException& e) {
                std::cerr << e.what() << std::endl;
                sleep(5);
                break;
            } catch (AmqpClient::ConnectionForcedException& e) {
                std::cerr << e.what() << std::endl;
                sleep(5);
                break;
            }
        }
    }

    channel->DeleteQueue(queue);

    return 0;
}
