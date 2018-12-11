using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.Text;
using System.Threading.Tasks;

namespace RQS_WPF
{
    [DataContract]
    internal class Status
    {
        [DataMember]
        internal int id;
        [DataMember]
        internal String name;

        public Status(int id, string name)
        {
            this.id = id;
            this.name = name;
        }

        public override bool Equals(object obj)
        {
            var status = obj as Status;
            return status != null &&
                   id == status.id &&
                   name == status.name;
        }

        public override int GetHashCode()
        {
            var hashCode = -48284730;
            hashCode = hashCode * -1521134295 + id.GetHashCode();
            hashCode = hashCode * -1521134295 + EqualityComparer<string>.Default.GetHashCode(name);
            return hashCode;
        }

        public override string ToString()
        {
            return base.ToString();
        }
    }
}
