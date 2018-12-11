using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.Text;
using System.Threading.Tasks;

namespace RQS_WPF
{
    [DataContract]
    internal class Realisateur
    {
        [DataMember]
        internal int id;
        [DataMember]
        internal String name;

        public Realisateur(int id, string name)
        {
            this.id = id;
            this.name = name;
        }

        public override bool Equals(object obj)
        {
            var realisateur = obj as Realisateur;
            return realisateur != null &&
                   id == realisateur.id &&
                   name == realisateur.name;
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
