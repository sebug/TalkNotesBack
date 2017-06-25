using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.ServiceModel;
using System.ServiceModel.Web;
using System.Text;

namespace TalkNotesBack
{
    // NOTE: You can use the "Rename" command on the "Refactor" menu to change the interface name "IService1" in both code and config file together.
    [ServiceContract]
    public interface ITalkNoteService
    {

        [OperationContract]
        TalkNote GetTalkNoteByID(int talkNoteID);

        [OperationContract]
        List<TalkNote> GetAll();
    }


    // Use a data contract as illustrated in the sample below to add composite types to service operations.
    [DataContract]
    public class TalkNote
    {
        private int _talkNoteID;
        private string _title;
        private string _body;

        [DataMember]
        public int TalkNoteID
        {
            get { return _talkNoteID; }
            set { _talkNoteID = value; }
        }

        [DataMember]
        public string Title
        {
            get { return _title; }
            set { _title = value; }
        }

        [DataMember]
        public string Body
        {
            get { return _body; }
            set { _body = value; }
        }
    }
}
