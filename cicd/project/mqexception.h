/******************************************************************************!
 * \file mqexception.h
 * \author Sebastien Beaugrand
 * \sa http://beaugrand.chez.com/
 * \copyright CeCILL 2.1 Free Software license
 ******************************************************************************/
#ifndef MQEXCEPTION_H
#define MQEXCEPTION_H
#include <amqp.h>

namespace mq {

class Exception : public std::exception
{
public:
    explicit Exception(const std::string& m, int c = 0) : mMesg(m), mCode(c) {}
    explicit Exception(amqp_rpc_reply_t res) {
        mCode = res.library_error;
        mMesg = amqp_error_string2(mCode);
    }
    const char* what() const noexcept {
        if (mCode == 0) {
            return mMesg.c_str();
        } else {
            return (mMesg + " errno = " + std::to_string(mCode)).c_str();
        }
    }
private:
    std::string mMesg;
    int mCode = 0;
};

}

#endif
