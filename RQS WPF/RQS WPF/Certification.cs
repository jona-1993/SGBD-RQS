using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.Text;
using System.Threading.Tasks;

namespace RQS_WPF
{
    [DataContract]
    internal class Certification
    {
        [DataMember]
        internal int id;
        [DataMember]
        internal String code;
        [DataMember]
        internal String name;
        [DataMember]
        internal String definition;
        [DataMember]
        internal String description;

        public Certification(int id, string code, string name, string definition, string description)
        {
            this.id = id;
            this.code = code;
            this.name = name;
            this.definition = definition;
            this.description = description;
        }

        public override bool Equals(object obj)
        {
            var certification = obj as Certification;
            return certification != null &&
                   id == certification.id &&
                   code == certification.code &&
                   name == certification.name &&
                   definition == certification.definition &&
                   description == certification.description;
        }

        public override int GetHashCode()
        {
            var hashCode = -1422771837;
            hashCode = hashCode * -1521134295 + id.GetHashCode();
            hashCode = hashCode * -1521134295 + EqualityComparer<string>.Default.GetHashCode(code);
            hashCode = hashCode * -1521134295 + EqualityComparer<string>.Default.GetHashCode(name);
            hashCode = hashCode * -1521134295 + EqualityComparer<string>.Default.GetHashCode(definition);
            hashCode = hashCode * -1521134295 + EqualityComparer<string>.Default.GetHashCode(description);
            return hashCode;
        }

        public override string ToString()
        {
            return base.ToString();
        }
    }
}
