using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.Text;
using System.Threading.Tasks;

namespace RQS_WPF
{
    [DataContract]
    internal class Genre
    {
        [DataMember]
        internal int id;
        [DataMember]
        internal String name;

        public Genre(int id, string name)
        {
            this.id = id;
            this.name = name;
        }

        public override bool Equals(object obj)
        {
            var genre = obj as Genre;
            return genre != null &&
                   id == genre.id &&
                   name == genre.name;
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
